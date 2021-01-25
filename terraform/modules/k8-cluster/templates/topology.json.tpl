{
  "clusters": [
    {
      "nodes": [
        {
          "node": {
            "hostnames": {
              "manage": [
                "${name_k8_worker_0}"
              ],
              "storage": [
                "${ip_k8_worker_0}"
              ]
            },
            "zone": 1
          },
          "devices": [
            "/dev/xvdh"
          ]
        },
        {
          "node": {
            "hostnames": {
              "manage": [
                "${name_k8_worker_1}"
              ],
              "storage": [
                "${ip_k8_worker_1}"
              ]
            },
            "zone": 1
          },
          "devices": [
            "/dev/xvdh"
          ]
        },
        {
          "node": {
            "hostnames": {
              "manage": [
                "${name_k8_worker_2}"
              ],
              "storage": [
                "${ip_k8_worker_2}"
              ]
            },
            "zone": 1
          },
          "devices": [
            "/dev/xvdh"
          ]
        }
      ]
    }
  ]
}