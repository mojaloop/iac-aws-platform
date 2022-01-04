#!/usr/bin/python3
from __future__ import absolute_import, division, print_function
import logging
import xml.etree.ElementTree as ET
import yaml
import json
import urllib.parse
import requests
from statemachine.exceptions import TransitionNotAllowed
from statemachine import StateMachine, State
from ansible.module_utils.basic import AnsibleModule
import os

# Copyright: (c) 2020, David Gethings <david.gethings@modusbox.com>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

ANSIBLE_METADATA = {
    "metadata_version": "0.2.0",
    "status": ["preview"],
    "supported_by": "community",
}

DOCUMENTATION = """
---
module: wso2_api_publisher

short_description: Update WSO2 API gateway with API definition from Mojaloop

version_added: "2.9"

description:
    - "With a given API template file (JSON) will publish or delete API"
    - "When publishing an API both the URL to get the API definition and the endpoint URL from is required"
    - "Adding mediations is supported"
    - "Will publish a new API if the API definition version does not match what is on Mojaloop"
    - "Will publish a new API if the API mediations are changed (specifically the names)"

options:
    hostname:
        description:
            - Hostname of the WSO2 service
        required: true
        type: str
    token_hostname
        description:
            - Hostname of the WSO2 token service
        required: true
        type: str
    username:
        description:
            - Username used for initial authentication to WSO2
        required: false
        default: "admin"
        type: str
    password:
        description:
            - Password use for inital authentication to WSO2
        required: false
        default: "admin"
        type: str
    rest_port:
        description:
            - WSO2 ReST API port number
        required: false
        default: 443
        type: int
    token_port:
        description:
            - WSO2 port number for performing functions with that API
        required: false
        default: 443
        type: int
    client_reg_path:
        description:
            - URL path to WSO2 client registration function
        required: false
        default: "/client-registration/v0.14/register"
        type: str
    api_path:
        description:
            - URL path to WSO2 registered API
        required: false
        default: "/api/am/publisher/v0.14/apis"
        type: str
    token_path:
        description:
            - URL path to WSO2 token request service
        required: false
        default: "/token"
        type: str
    verify_ssl:
        description:
            - Determines whether to validate WSO2 SSL cert or not
        required: false
        default: False
        type: bool
    api_template:
        description:
            - Filename of WSO2 API template
        required: true
        type: path
    inbound_mediation:
        description:
            - List of inbound mediations to apply to the WSO2
        required: false
        type: list
    outbound_mediation:
        description:
            - List of outbound mediations to apply to the WSO2
        required: false
        type: list
    fault_mediation:
        description:
            - List of fault mediations to apply to the WSO2
        required: false
        type: list
    swagger_url:
        description:
            - URL to GET Swagger API definition from
        required: false
        type: str
    endpoint_url:
        description:
            - URL of Mojaloop endpoint used with WSO2 API
        required: false
        type: str
    state:
        description:
            - The desired state for the API. Absent removes (if present) the API from WSO2. Published added the API (and any mediations specified) to WSO2
        type: str
        required: false
        default: "published"
        choices:
            - "absent"
            - "published"

author:
    - David Gethings (@dgethings)

requirements:
    - python-statemachine-0.8.0
"""

EXAMPLES = """
# delete API specifying mediations to also delete
- name: delete API with mediations
  wso2_api_publisher:
    hostname: extgw.otc-546.infra.modusbox.io
    api_template: fspiop/api_template.json
    inbound_mediation:
        - "fspiop/add_accept_header.xml"
    state: absent

# delete API without specifying mediations. Mediations will still be deleted
- name: delete API without mediations
  wso2_api_publisher:
    hostname: extgw.otc-546.infra.modusbox.io
    api_template: fspiop/api_template.json
    state: absent

# publish API with no mediations
- name: publish API without mediations
  wso2_api_publisher:
    hostname: extgw.otc-546.infra.modusbox.io
    api_template: fspiop/api_template.json
    swagger_url: "http://account-lookup-service.otc-546.infra.modusbox.io.internal:30000/api-docs"
    endpoint_url: "http://account-lookup-service-admin.otc-546.infra.modusbox.io.internal:30000"

# publish API with mediations
- name: publish API with mediations
  wso2_api_publisher:
    hostname: extgw.otc-546.infra.modusbox.io
    api_template: fspiop/api_template.json
    swagger_url: "http://account-lookup-service.otc-546.infra.modusbox.io.internal:30000/api-docs"
    endpoint_url: "http://account-lookup-service-admin.otc-546.infra.modusbox.io.internal:30000"
    inbound_mediation:
        - "fspiop/add_accept_header.xml"
"""

RETURN = """
context:
    description: URL path of the API
    type: str
    returned: always
api_definition_version:
    description: Version number of the API version
    type: str
    returned: always
mediations:
    description: List of mediations associated with the API
    type: list
    returned: always
"""


# use this for debugging only
logging.basicConfig(level=os.environ.get("MODULE_LOGLEVEL", "INFO").upper())


class WSO2(StateMachine):
    init = State("init", initial=True)
    loaded = State("loaded")
    absent = State("absent")
    outdated = State("outdated")
    created = State("created")
    published = State("published")

    load = init.to(loaded)
    in_progress = loaded.to(created)
    current = loaded.to(published)
    outdate = loaded.to(outdated)
    new = loaded.to(absent)
    create = absent.to(created)
    publish = created.to(published)
    update = outdated.to(published)
    delete = absent.from_(created, outdated, published)

    def state(self):
        """
        Get the current state

        Returns:
            [str]: String name of the current state
        """
        return self.current_state.identifier

    def on_load(self):
        new["api"] = self._load_wso2_template(module.params["api_template"])
        new["mediations"] = self._load_mediations()
        current["api"] = self.get_wso2_api()
        self._log("loaded APIs from files and WSO2 service")

    def on_enter_loaded(self):
        self._log("figuring out starting state")

        # There is no API on WSO2
        if not current["api"]:
            self.new()
        # There is an API on WSO2 but the version or mediations are wrong
        elif self._api_needs_update():
            self.outdate()
        # Something went wrong before so API there but not in published state
        elif current["api"]["status"] == "CREATED":
            self.in_progress()
        # WSO2 API is published
        elif current["api"]["status"] == "PUBLISHED":
            self.current()
        # we should never get here
        else:
            raise Exception("Invalid state", {new: new, current: current})

    def load_new_api(self):
        new["api"]["apiDefinition"] = self.get_swagger()
        new["api"]["endpointConfig"]["production_endpoints"]["url"] = module.params[
            "endpoint_url"
        ]

        # add WSO2 attributes
        for path in new["api"]["apiDefinition"]["paths"].values():
            for verb in path.values():
                if type(verb) is dict:
                    verb["x-auth-type"] = "Application & Application User"
                    verb["x-throttling-tier"] = "Unlimited"

    def _add_path_attrs(self, swagger):
        return

    def on_create(self):
        self._log(f"creating WSO2 API {new['api']['name']}")
        # do a .copy() to avoid changing the new["api"] dict
        current["api"] = self.create_wso2_api(api=new["api"].copy())
        if new["mediations"]:
            self._log(f"found mediations for API {new['api']['name']}")
            current["api"]["sequences"] = self.create_mediations(
                mediations=new["mediations"]
            )
            self.update_api(api=current["api"].copy())

    def on_publish(self):
        """
        Publish the WSO2 API for a given API ID

        Args:
            module (obj): The AnsibleModule. Used to get the params passed by the user
            session (dict): Data used to perform requests
        """
        self._log(f"publishing WSO2 API {new['api']['name']}")
        p = module.params

        request = dict(
            url=f"https://{p['hostname']}:{p['rest_port']}{p['api_path']}/change-lifecycle?apiId={self.api_id()}&action=Publish",
            headers=dict(Authorization=f"Bearer {self.publish_token()}"),
            verify=p["verify_ssl"],
        )

        resp = self._do_post(request)

        if not resp.ok:
            self._fail(
                msg=f"Publish API {new['api']['name']} failed.", err=resp.json())

    def _fail(self, msg, err):
        """
        Constructs error message to pass to Ansible. Execution of module will end here in failure

        Args:
            msg (str): Description of error
            err (dict): requests.Response.json() object
        """
        message = msg + \
            f" {err.get('code', err.get('errorCode', '-1'))} {err['message']}: {err.get('description', err.get('errorDescription', json.dumps(err)))}"
        module.fail_json(msg=message)

    def on_update(self):
        self._log(f"updating WSO2 API {new['api']['name']}")

        if self._api_versions_different():
            current["api"]["apiDefinition"] = new["api"]["apiDefinition"]

        if self._mediations_different():
            for mediation in current["api"]["sequences"]:
                self._log(f"deleting mediation {mediation['name']}")
                self._delete_mediation(mediation)

            current["api"]["sequences"] = self.create_mediations(
                mediations=new["mediations"]
            )

        self.update_api(api=current["api"].copy())

    def _delete_write_once_fields(self, api):
        del api["name"]
        del api["version"]
        del api["context"]
        del api["provider"]
        del api["status"]

        return api

    def on_delete(self):
        for mediation in current["api"]["sequences"]:
            self._log(f"deleting mediation {mediation['name']}")
            self._delete_mediation(mediation)

        self._delete_wso2_api(current["api"])

    def _load_wso2_template(self, api_file):
        """
        Loads WSO2 API template file provided by the user

        Args:
            api_file (str): filename of the API template to load

        Returns:
            dict: representing API in JSON format
        """
        self._log(f"loading template {api_file}")
        try:
            with open(api_file) as json_file:
                return yaml.safe_load(json_file)
        except FileNotFoundError as e:
            module.fail_json(msg=str(e))

    def _load_mediations(self):
        """
        Iterates through the various mediation files and generates WSO2 mediation API.

        Returns:
            [list]: list of JSON compatable dict() for each mediation
        """
        self._log(
            "loading mediations: "
            + ", ".join(module.params["inbound_mediation"])
            + ", ".join(module.params["outbound_mediation"])
            + ", ".join(module.params["fault_mediation"])
        )

        mediations = list()

        for file in module.params["inbound_mediation"]:
            mediations.append(self._load_mediation(file, "in"))

        for file in module.params["outbound_mediation"]:
            mediations.append(self._load_mediation(file, "out"))

        for file in module.params["fault_mediation"]:
            mediations.append(self._load_mediation(file, "fault"))

        return mediations

    def _load_mediation(self, file, med_type):
        """
        Loads the given mediation file (XML formatted) and returns a WSO2 mediation API compatable JSON blob

        Args:
            module (obj): The AnsibleModule. Used to get the params passed by the user
            file (str): path to the mediation XML file
            med_type (str): needs to be one of "in", "out" or "fault"

        Returns:
            [dict]: JSON compatable dict() of the WSO2 mediation API
        """
        self._log(f"loading mediation: {file}")
        try:
            with open(file) as xml_file:
                xml_data = xml_file.read()
        except FileNotFoundError as e:
            module.fail_json(msg=str(e))

        return dict(
            name=ET.fromstring(
                xml_data).attrib["name"], type=med_type, config=xml_data,
        )

    def get_swagger(self):
        """
        Queries given URL to get the Swagger definition from Mojaloop component

        Returns:
            dict: a JSON datastructure representing the Swagger definition
        """
        self._log(f"get API definition from {module.params['swagger_url']}")

        request = dict(url=module.params["swagger_url"])
        resp = self._do_get(request)

        if not resp.ok:
            try:
              err=resp.json()
            except:
              err={"message": "invalid json output: {}".format(resp.text)}
            self._fail(
                msg=f"Get API definition from {module.params['swagger_url']} failed.",
                err=err,
            )

        return yaml.safe_load(resp.content)

    def client_token(self):
        """
        Get client auth token using given username and password

        Args:
            module (obj): The AnsibleModule. Used to get the params passed by the user

        Returns:
            dict: Token comprising of an ID and secret for use with authenticating further requests
        """
        if hasattr(self, "_client_token"):
            return self._client_token

        self._log("getting client token")
        p = module.params

        request = dict(
            url=f"https://{p['hostname']}:{p['rest_port']}{p['client_reg_path']}",
            json=dict(
                callbackUrl="www.example.com",
                clientName="rest_api_publisher",
                owner="admin",
                grantType="password refresh_token",
                saasApp="true",
            ),
            auth=(p["username"], p["password"]),
            verify=p["verify_ssl"],
        )

        resp = self._do_post(request).json()
        self._client_token = (resp["clientId"], resp["clientSecret"])
        return self._client_token

    def view_token(self):
        if hasattr(self, "_view_token"):
            return self._view_token

        self._view_token = self._get_token(type="view")
        return self._view_token

    def create_token(self):
        if hasattr(self, "_create_token"):
            return self._create_token

        self._create_token = self._get_token(type="create")
        return self._create_token

    def publish_token(self):
        if hasattr(self, "_publish_token"):
            return self._publish_token

        self._publish_token = self._get_token(type="publish")
        return self._publish_token

    def get_wso2_api(self):
        """
        Get the WSO2 API - including Swagger defintion - for a given API template

        This function drives the logic flow for this application. It sets the session

        Args:
            module (obj): The AnsibleModule. Used to get the params passed by the user
            session (dict): Data used to perform requests

        Returns:
            dict: updated version of the passed in seesion dict
        """
        self._log("getting API from WSO2")
        p = module.params
        api = dict()

        # No api_id means there is no API for the requested template
        # so exit here. session dict is already None, so no need to change
        if not self.api_id():
            return

        # a WSO2 API exists so get it's details
        current["mediations"] = self.get_wso2_mediations()

        request = dict(
            url=f"https://{p['hostname']}:{p['rest_port']}{p['api_path']}/{self.api_id()}",
            headers={
                "Authorization": f"Bearer {self.view_token()}",
                "Content-Type": "application/x-www-form-urlencoded",
            },
            verify=p["verify_ssl"],
        )

        resp = self._do_get(request)

        if not resp.ok:
            try:
              err=resp.json()
            except:
              err={"message": "invalid json output: {}".format(resp.text)}
            self._fail(msg=f"Get API failed.", err=resp)

        api = resp.json()
        # convert json string to json object (handy in the rest of the code)
        api["apiDefinition"] = yaml.safe_load(api["apiDefinition"])

        return api

    def _do_get(self, request):
        request = self._add_headers(request)
        try:
            return requests.get(**request)
        except Exception as e:
            module.fail_json(msg=str(e))

    def _do_post(self, request):
        request = self._add_headers(request)
        try:
            return requests.post(**request)
        except Exception as e:
            module.fail_json(msg=str(e))

    def _do_put(self, request):
        request = self._add_headers(request)
        try:
            return requests.put(**request)
        except Exception as e:
            module.fail_json(msg=str(e))

    def _do_delete(self, request):
        request = self._add_headers(request)
        try:
            return requests.delete(**request)
        except Exception as e:
            module.fail_json(msg=str(e))

    def _add_headers(self, request):
        try:
            request["headers"]["User-Agent"] = "wso2-api/0.1.0"
        except KeyError:
            request["headers"] = {"User-Agent": "wso2-api/0.1.0"}

        return request

    def _get_token(self, type):
        self._log(f"getting {type} token")
        p = module.params

        request = dict(
            url=f"https://{p['token_hostname']}:{p['token_port']}{p['token_path']}",
            headers={"Content-Type": "application/x-www-form-urlencoded", },
            data=dict(
                grant_type="password",
                username=p["username"],
                password=p["password"],
                scope=f"apim:api_{type}",
            ),
            auth=self.client_token(),
            verify=p["verify_ssl"],
        )

        try:
            return self._do_post(request).json()["access_token"]
        except requests.exceptions.RequestException as e:
            module.fail_json(msg=str(e))

    def api_id(self):
        """
        Get the WSO2 API ID for a given API.

        Args:
            module (obj): The AnsibleModule. Used to get the params passed by the user
            session (dict): Data used to perform requests

        Returns:
            str: WSO2 ID for the given API
        """
        if current["api"].get("id"):
            return current["api"]["id"]

        self._log("getting WSO2 API ID")
        p = module.params

        request = dict(
            url=f"https://{p['hostname']}:{p['rest_port']}{p['api_path']}?query=context:{new['api']['context']}",
            headers={
                "Authorization": f"Bearer {self.view_token()}",
                "Content-Type": "application/x-www-form-urlencoded",
            },
            verify=p["verify_ssl"],
        )

        resp = self._do_get(request).json()

        try:
            current["api"]["id"] = resp["list"][0]["id"]
            return current["api"]["id"]
        except IndexError:
            self._log(f"API {new['api']['context']} not found on WSO2")
            return None

    def get_wso2_mediations(self):
        """
        Retrieve list of mediations defined with the API

        Args:
            module (obj): The AnsibleModule. Used to get the params passed by the user
            session (dict): Data used to perform requests

        Returns:
            [list]: JSON structs defining list of mediations with API
        """
        self._log("getting migriations from WSO2")
        p = module.params

        request = dict(
            url=f"https://{p['hostname']}:{p['rest_port']}{p['api_path']}/{self.api_id()}/policies/mediation",
            headers={
                "Authorization": f"Bearer {self.view_token()}",
                "Content-Type": "application/x-www-form-urlencoded",
            },
            verify=p["verify_ssl"],
        )

        try:
          resp = self._do_get(request)
          return resp.json()["list"]
        except:
          err={"message": "invalid json output: {}".format(resp.text)}
          self._fail(
                msg=f"Failed to get mediations. Invalid json:", err=err)  

    def create_wso2_api(self, api):
        """
        Create the WSO2 API - including Swagger defintion - for a given API template

        Args:
            module (obj): The AnsibleModule. Used to get the params passed by the user
            session (dict): Data used to perform requests

        Returns:
            str: WSO2 ID for the created API
        """
        self._log(f"create WSO2 API {api['context']}")
        p = module.params

        # apiDefinitions and endpointConfig need to be stringified JSON
        api["apiDefinition"] = json.dumps(api["apiDefinition"])
        api["endpointConfig"] = json.dumps(api["endpointConfig"])

        request = dict(
            url=f"https://{p['hostname']}:{p['rest_port']}{p['api_path']}",
            headers=dict(Authorization=f"Bearer {self.create_token()}"),
            json=api,
            verify=p["verify_ssl"],
        )

        resp = self._do_post(request)

        if resp.status_code != 201:
            self._fail(
                msg=f"Create API {api['name']} failed.", err=resp.json())

        return resp.json()

    def create_mediations(self, mediations):
        self._log("creating mediations")
        p = module.params
        wso2_mediations = list()

        request = dict(
            url=f"https://{p['hostname']}:{p['rest_port']}{p['api_path']}/{self.api_id()}/policies/mediation",
            headers=dict(Authorization=f"Bearer {self.create_token()}"),
            verify=p["verify_ssl"],
        )

        for mediation in mediations:
            request["json"] = mediation
            resp = self._do_post(request)

            if resp.status_code != 201:
                self._fail(
                    msg=f"Create API mediation {resp.request.body['name']} failed.",
                    err=resp.json(),
                )

            # remove config from sequences before updating the API with them
            med = resp.json()
            del med["config"]
            wso2_mediations.append(med)

        return wso2_mediations

    def update_api(self, api):
        """
        Create the WSO2 API - including Swagger defintion - for a given API template

        Args:
            module (obj): The AnsibleModule. Used to get the params passed by the user
            session (dict): Data used to perform requests

        Returns:
            str: WSO2 ID for the created API
        """
        self._log(f"updating API {api['name']}")
        p = module.params

        api = self._delete_write_once_fields(api=api)

        # apiDefinitions and endpointConfig need to be stringified JSON
        if type(api["apiDefinition"]) is not str:
            api["apiDefinition"] = json.dumps(api["apiDefinition"])

        if type(api["endpointConfig"]) is not str:
            api["endpointConfig"] = json.dumps(api["endpointConfig"])

        request = dict(
            url=f"https://{p['hostname']}:{p['rest_port']}{p['api_path']}/{self.api_id()}",
            json=api,
            headers=dict(Authorization=f"Bearer {self.create_token()}"),
            verify=p["verify_ssl"],
        )

        resp = self._do_put(request)

        if not resp.ok:
            self._fail(
                msg=f"Update API {api['name']} with mediations failed.", err=resp.json()
            )

    def _delete_mediation(self, mediation):
        p = module.params

        request = dict(
            url=f"https://{p['hostname']}:{p['rest_port']}{p['api_path']}/{self.api_id()}/policies/mediation/{mediation['id']}",
            headers=dict(Authorization=f"Bearer {self.create_token()}"),
            verify=p["verify_ssl"],
        )

        resp = self._do_delete(request)

        if not resp.ok:
            self._fail(
                msg=f"Delete API mediation {mediation['name']} failed.",
                err=resp.json(),
            )

    def _delete_wso2_api(self, api):
        self._log(f"deleting WSO2 API {api['name']}")
        p = module.params

        request = dict(
            url=f"https://{p['hostname']}:{p['rest_port']}{p['api_path']}/{self.api_id()}",
            headers=dict(Authorization=f"Bearer {self.create_token()}"),
            verify=p["verify_ssl"],
        )

        resp = self._do_delete(request)

        if not resp.ok:
            self._fail(
                msg=f"Delete API {api['name']} failed.", err=resp.json())

    def _api_needs_update(self):
        """
        Checks to see if the API definition version in WSO2 matches the version running in Mojaloop

        Returns:
            bool: True if API versions differ (or no API on WSO2 service). Otherwise False
        """
        answer = any([self._api_versions_different(),
                      self._mediations_different()])
        self._log(f"api needs update {answer}")
        return answer

    def _log(self, msg):
        logging.debug("%s: %s" % (self.state().upper(), msg))

    def _api_versions_different(self):
        wso2_version = self._get_api_version(current["api"])
        mj_version = self._get_api_version(new["api"])

        answer = all([wso2_version, mj_version])
        self._log(f"api needs update {answer}")

        return answer

    def _get_api_version(self, api):
        try:
            return api["apiDefinition"]["info"]["version"]
        except Exception:
            return None

    def _mediations_different(self):
        cur_meds = list(map(lambda x: x["name"], current["api"]["sequences"]))
        new_meds = list(map(lambda x: x["name"], new["mediations"]))
        self._log(f"WSO2 mediations: {', '.join(cur_meds)}")
        self._log(f"new mediations: {', '.join(new_meds)}")
        self._log(f"mediations are the same {cur_meds != new_meds}")
        return cur_meds != new_meds

    def api_definition_version(self):
        try:
            return current["api"]["apiDefinition"]["info"]["version"]
        except Exception:
            try:
                return new["api"]["apiDefinition"]["info"]["version"]
            except Exception:
                return None

    def get_mediation_names(self):
        try:
            return [seq["name"] for seq in current["api"]["sequences"]]
        except Exception:
            return [seq["name"] for seq in new["mediations"]]


# Prep the global scoped variables
# Yes, in this instance we want to use global vars, but only these
module = None
current = dict(api=dict(), mediations=list())
new = current.copy()


def main():
    global module
    global current
    global new

    module_args = dict(
        hostname=dict(type="str", required=True),
        token_hostname=dict(type="str", required=True),
        username=dict(type="str", required=False, default="admin"),
        password=dict(type="str", required=False,
                      default="admin", no_log=True),
        rest_port=dict(type="int", required=False, default=443),
        token_port=dict(type="int", required=False, default=443),
        client_reg_path=dict(
            type="str", required=False, default="/client-registration/v0.14/register"
        ),
        api_path=dict(
            type="str", required=False, default="/api/am/publisher/v0.14/apis"
        ),
        token_path=dict(type="str", required=False, default="/token"),
        verify_ssl=dict(type="bool", required=False, default=False),
        api_template=dict(type="path", required=True),
        inbound_mediation=dict(type="list", required=False, default=list()),
        outbound_mediation=dict(type="list", required=False, default=list()),
        fault_mediation=dict(type="list", required=False, default=list()),
        swagger_url=dict(type="str", required=False),
        endpoint_url=dict(type="str", required=False),
        state=dict(
            type="str",
            required=False,
            default="published",
            choices=["absent", "published"],
        ),
    )

    result = dict(
        changed=False,
        context="",
        api_definition_version="",
        status="absent",
        mediations=list(),
    )

    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)

    # if verify_ssl is set to false prevent urllib3 from printing wanrings
    # to the console
    if not module.params["verify_ssl"]:
        import urllib3

        urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

    wso2 = WSO2()
    wso2.load()

    if module.check_mode:
        module.exit_json(changed=wso2.state() != module.params["state"])

    # If we're not deleting an existing API we're adding a new
    # so go get it and work out what to do
    if module.params["state"] != "absent":
        wso2.load_new_api()

    if wso2.state() != module.params["state"]:
        if module.params["state"] == "published":
            if wso2.state() == "absent":
                wso2.create()
            if wso2.state() == "created":
                wso2.publish()
            if wso2.state() == "outdated":
                wso2.update()

        elif module.params["state"] == "absent":
            wso2.delete()

        result["changed"] = True

    result["api_definition_version"] = wso2.api_definition_version()
    result["mediations"] = wso2.get_mediation_names()
    result["context"] = new["api"]["context"]
    result["status"] = module.params["state"]

    module.exit_json(**result)


if __name__ == "__main__":
    main()
