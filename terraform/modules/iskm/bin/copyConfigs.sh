#!/bin/sh
if [ -z "$(ls -A ${WSO2_SERVER_HOME}/repository/deployment/server/)" ]; then
    cp -r -a ${WORKING_DIRECTORY}/wso2-tmp/server/* ${WSO2_SERVER_HOME}/repository/deployment/server/
    echo "Updated server/ folder from temporary cache"
fi
mkdir -p $WSO2_SERVER_HOME/configs/FSP/
#copying configs and secrets to temp dirs assuming external configmap/secret creation process
mkdir -p ${WORKING_DIRECTORY}/conf ${WORKING_DIRECTORY}/secrets && cd ${WORKING_DIRECTORY}/conf && cp $CONF_MOUNT_PATH/* . && cd ${WORKING_DIRECTORY}/secrets && cp $SECRET_MOUNT_PATH/* . && cd -

sed -i "s/@API_GW_HOST@/$API_GW_HOST/g" ${WORKING_DIRECTORY}/conf/*
sed -i "s/@API_STORE_HOST@/$API_STORE_HOST/g" ${WORKING_DIRECTORY}/conf/*
sed -i "s/@API_PUB_HOST@/$API_PUB_HOST/g" ${WORKING_DIRECTORY}/conf/*
sed -i "s/@WSO2_DB_HOST@/$WSO2_DB_HOST/g" ${WORKING_DIRECTORY}/conf/*
sed -i "s/@WSO2_DB_PORT@/$WSO2_DB_PORT/g" ${WORKING_DIRECTORY}/conf/*
sed -i "s/@WSO2_DB_USER@/$WSO2_DB_USER/g" ${WORKING_DIRECTORY}/conf/*
sed -i "s/@WSO2_DB_PW@/$WSO2_DB_PW/g" ${WORKING_DIRECTORY}/conf/*
sed -i "s/@ISKM_HOST@/$ISKM_HOST/g" ${WORKING_DIRECTORY}/conf/*
sed -i "s/@KEYSTORE_PASSWORD@/$KEYSTORE_PASSWORD/g" ${WORKING_DIRECTORY}/conf/*
sed -i "s/@WSO2_ADMIN_PW@/$WSO2_ADMIN_PW/g" ${WORKING_DIRECTORY}/conf/*

# standard configuration files
cp ${WORKING_DIRECTORY}/conf/application-authentication.xml $WSO2_SERVER_HOME/repository/conf/identity/application-authentication.xml
cp ${WORKING_DIRECTORY}/conf/api-manager.xml $WSO2_SERVER_HOME/repository/conf/api-manager.xml
cp ${WORKING_DIRECTORY}/conf/carbon.xml $WSO2_SERVER_HOME/repository/conf/carbon.xml
cp ${WORKING_DIRECTORY}/conf/identity.xml $WSO2_SERVER_HOME/repository/conf/identity/identity.xml
cp ${WORKING_DIRECTORY}/conf/master-datasources.xml $WSO2_SERVER_HOME/repository/conf/datasources/master-datasources.xml
cp ${WORKING_DIRECTORY}/conf/registry.xml $WSO2_SERVER_HOME/repository/conf/registry.xml
cp ${WORKING_DIRECTORY}/conf/user-mgt.xml $WSO2_SERVER_HOME/repository/conf/user-mgt.xml
cp ${WORKING_DIRECTORY}/conf/log4j.properties $WSO2_SERVER_HOME/repository/conf/log4j.properties
#cp ${WORKING_DIRECTORY}/conf/oidc-scope-config.xml $WSO2_SERVER_HOME/repository/conf/identity/oidc-scope-config.xml

# java keystores (jks)
#TODO: this will change with dynamic lookups from vault, for now, building the jks files from the key, certs
cd ${WORKING_DIRECTORY}/secrets
#remove any leftover jks files
rm -f *.jks
#declare alias locally
SIMPLE_ALIAS=iskm
#create pkcs12 keystore with key, cert and root ca
openssl pkcs12 -export -in cert.pem -inkey key.pem -name $SIMPLE_ALIAS -certfile root_ca.pem -password pass:$KEYSTORE_PASSWORD -out ./wso2carbon.pfx
#import pkcs12 keystore into new java key store
keytool -importkeystore -srckeystore ./wso2carbon.pfx -srcstoretype pkcs12 -destkeystore wso2carbon.jks -deststoretype JKS -deststorepass $KEYSTORE_PASSWORD --srcstorepass $KEYSTORE_PASSWORD -destalias wso2carbon -srcalias $SIMPLE_ALIAS
#create truststore with imported root ca
keytool -importcert -file ./root_ca.pem -keystore ./client-truststore.jks -storetype JKS -storepass $KEYSTORE_PASSWORD -alias acme-ca -noprompt

#copy certs jks into correct wso2 dir
cp ${WORKING_DIRECTORY}/secrets/wso2carbon.jks $WSO2_SERVER_HOME/repository/resources/security/wso2carbon.jks
#copy root ca jks into correct wso2 dir
cp ${WORKING_DIRECTORY}/secrets/client-truststore.jks $WSO2_SERVER_HOME/repository/resources/security/client-truststore.jks
