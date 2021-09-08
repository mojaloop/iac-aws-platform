mojaloop-simulator:
  enabled: ${internal_sim_enabled}
  # Default values for mojaloop-simulator.
  # This is a YAML-formatted file.
  # Declare variables to be passed into your templates.

  # Usage:
  # Add simulators to the simulators object. The following example will create two simulators,
  # 'payerfsp' and 'payeefsp' that will be created with the default values available lower in this
  # file.
  #
  # simulators:
  #   payerfsp: {}
  #   payeefsp: {}
  #
  # The default values can be overridden for all sims by modifying mojaloop-simulator.defaults in
  # your parent chart. They can also be overriden per-simulator. The following example will result in
  # a payerfsp without a cache and a payeefsp with a cache.
  #
  # simulators:
  #   payerfsp:
  #     config:
  #       cache:
  #         enabled: false
  #   payeefsp: {}

  # TODO & notes:
  # * do the port _numbers_ matter at all? Can we get rid of them?
  # * for Mowali, how are JWS and TLS secrets being set up?
  # * support arbitrary init containers + config (that might just be config that goes into defaults
  #   or something?). Supply all config and volumes to the init containers.
  # * create some test containers
  # * parametrise imagePullSecretName (global? like https://github.com/bitnami/charts/tree/master/bitnami/redis#parameters)
  # * generate JWS private/public keys, so the user does not need to supply keys at all.
  # * generate public key from private, so the user only needs to supply private keys for each sim?
  #   (_might_ be possible with a job or init container or similar).
  # * support mTLS auto-cert generation
  # * probably eliminate all config that shouldn't actually be changed by a user, e.g.
  #   JWS_VERIFICATION_KEYS_DIRECTORY. That's a good configuration option to have for other contexts,
  #   such as running the sim locally or in docker-compose but in this context it's _an
  #   implementation detail_. The chart user should not have to worry about it, and we should not
  #   have to test the effect of changing it.
  #   Also
  #   INBOUND_LISTEN_PORT
  #   OUTBOUND_LISTEN_PORT
  # * make ingress more generic- do not preconfigure annotations
  # * think about labels a little more carefully- the app should probably always be "mojaloop-simulator"
  # * add config map and hashes to the deployments so that a configmap change triggers a rolling
  #   update
  # * support JWS public keys for other entities. Add a note in the documentation that they must map
  #   directly to the value that will be received in the FSPIOP-Source (check this is correct)
  # * update labels to be compliant. E.g. app.kubernetes.io/name or whatever
  # * rename ".Values.defaults.config" as it's pretty a useless name
  # * support arbitrary sidecars?
  # * use the redis subchart? https://github.com/bitnami/charts/tree/master/bitnami/redis
  #   - this would mean a single instance of redis (probably good)
  #   - might need to have the simulators use separate databases per simulator, or prefix all of
  #     their keys with their own name, or something
  # * allow the user to optionally specify the namespace, with the caveat that that namespace will
  #   need to be created manually before the release is deployed. There may be a horrible hack (which
  #   I have not tried) whereby all templates are moved to a different directory, say ./xtemplates,
  #   then all are imported using {{ .Files.Glob }} and {{ .Files.Get }} then templated into a single
  #   amazing template with {{ template }}. At the top of this template goes a namespace. The
  #   consequence of this is that the namespace is created first, enabling this beautiful pattern.
  #   Remember, with great power comes great responsibility. (In other words, we probably have a
  #   responsibility to _not_ do this).
  # * should redis be a statefulset? optionally? what does the bitnami chart do?
  # * move labels into helpers
  # * autogenerate ILP stuff?
  # * defaults.resources looks like it's used nowhere- check this and remove it as appropriate
  # * look for references to replicaCount in the charts/values. Is it set, or whatever?
  # * scale Redis
  # * changing JWS_SIGNING_KEY_PATH currently breaks the chart because it's nastily hard-coded. It
  #   should be possible to use the Spring filepath functions to avoid this. Similarly, changing
  #   RULES_FILE will have a similar effect. Alternatively, make these unconfigured by default. I.e.
  #   comment them out, hard-code them and add a warning to the user in the config. (Is there a
  #   scenario where the user should want to configure them? I don't think so..).
  #   (https://masterminds.github.io/sprig/paths.html)
  # * put sim inbound API on port 80
  # * supply more documentation, especially a range of examples, and preferably documentation that is
  #   executable
  # * share configmaps, secrets with init containers
  # * share an emptyDir volume between init containers and main containers
  # * allow init containers to create secrets and put them on persistent volumes, or emptyDirs, then
  #   allow main containers to access those
  # * do not put environment variables in configmaps, instead put them straight into the deployments.
  #   This makes the deployment much easier to manage.
  # * Remember, labels are _for_ identifying stuff. So labels should probably be like "release"
  #   (.Release.Name or similar) "chart" (.Chart.Name or similar) "simulator" (e.g. payerfsp,
  #   payeefsp) "sim-component" (e.g. backend, scheme-adapter, cache)
  # * can _probably_ remove port numbers from services to simplify chart (although perhaps not? try
  #   to port-forward with a named port instead of a numbered port?)


  simulators:
    ## Every key added to this `simulators` object will be a simulator that takes on the default
    ## config below. The default is deliberately left empty so nothing is deployed by default.
    # payerfsp: {}
    # payeefsp: {}
    ## Default FSPs for Mojaloop Postman Scripts
    ${sim_prefix}payerfsp:
      ingress:
        hosts:
          - sim-${sim_prefix}payerfsp.local
      config:
        schemeAdapter:
          secrets:
            jws:
              # The following is an example key and shouldn't be used in production
              privateKey: |-
                -----BEGIN PRIVATE KEY-----
                MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCg9eU66hg4ZAE6
                jM4U8ylXQwUz9cdmzS3JyW+1bbgv77peMKSU/wFsi4QRwmbrYze9baFnGCKnS75E
                vCchib5vJxp3MDWzi/TGxmzgWdJRzkyCiI5C6dCgVL71MjsFgN3TN63wEf5sEU2I
                eoJ8yXJM0pUG9f9NO7p/IGliDmt6C7EA7D9kQWigufmX0ZTVNKI07fKwC/AEKLp7
                kx99pvsCq8m184EEL15Q/NhA7R/5zKoHvmJa6Jd7tM0i0xn8IKOkNVFu3YIafAEC
                QWQwRbanFEeRc3tH3bEoYM8c74r+W+YxCG7nUf16XCk132XVffbHVl+wFgo18YB/
                sAJmcbePAgMBAAECggEAGQGKnsf+gkg7DqMQYx3Rxt5BISzmURjAK9CxG6ETk9Lt
                A7QP5ZvmVzwnhPDMN3Z/Et1EzXTo8U+pnBkVBTdWkAMlr+2b8ixklzr9cC9UJuRj
                a4YWf9u+TyJLVmF63OSD0cwdKCZLffOENZc+zW8oZDn08BNomdGVLCnXZWXzGY8X
                KaJTJr29jEgkKOqFXdAHrsmj7TBtqSLZKx2IHdCmi05+5JCxVLPgnDiCicZ9zEii
                yWw57Q1migFIcw6ZQP4RyjgH1o70B+zo3OL7IQEirE17GUgK16XD8xi8hWCYTj5n
                xOz9yfVfPuYom/9Xbm5kYJZKE2HOZ3Lg8pUnWncuNQKBgQDbaOoACQPhVxQK1qYR
                RbW0I5Rn0EDxzsFPEpu3eXHoIYGXi8u/ew9AzFmGu+tKYJV5V4BCXo5x2ddE+B8B
                dXhyHLGfeV8tWKYKBpatolVxxKDL/9fnxoGIAO9cc91ieOm5JxmKscCVP1UnOXHZ
                uomSfAbGQwYDtMd2bJKkE1z0qwKBgQC7zacuv1PMaDFksHuNNRG+aZ74pJ77msht
                vJoKyaQcktD0xmIXhFfJvK4cclzG7s5jxCsu2ejimgmfVzgXlLEMrJFvSdFkD2SS
                gGqoxq5c9g8ssvt7xwr7aJ+VYYWTWRzJrOUny+99UbwHedu0EHL1BYILwy67Lium
                sgUeeCEgrQKBgGv+7f7qcRB/jgvvr3oc990dDjUzGmRrQlcrb54Vlu2NYH45fyZW
                6iEY9JAO+zd25tv9J9KDPFXpxb3a61gKfCie2wcF9MUbN08EAzKgDrKa+BKxcZJR
                8PwCic7V8QhBP7m09yt/Zq2PqNhPvCxRVtnVVnhMES/N0cgGlP9R0JVVAoGAHU2/
                kmnEN5bibiWjgasQM7fjWETHkdbbA1R0bM59zv+Rnz/9OlIqKI5KVKH7nAbTKXoI
                iuzxi7ohWj2PwQ4wehvLLaRFCenk9X8YJXGq71Jtl7ntx6iNLCFtFS/8WbuD5GwX
                7ZfCrLk+L6RyBayzY0wSuKch+Y8AvKf2aISyFpkCgYEAjSfEjz9Cn+27HdiMoBwa
                +fyyoosci/6OBxj/WTKvV6KUYLBfFoAYpb9rqrbvnfyyc0UiAYQeMJAOWQ1kkzY4
                zXs63iPQi2UeGPJZ7RsT+31DSaG9YiQdrInsUrlm8hi1C7Pg/NNt6Y1G0WhWYrvF
                iNK0yCENMhSoOTtbT9tmGi0=
                -----END PRIVATE KEY-----
              publicKey: |-
                -----BEGIN PUBLIC KEY-----
                MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoPXlOuoYOGQBOozOFPMp
                V0MFM/XHZs0tyclvtW24L++6XjCklP8BbIuEEcJm62M3vW2hZxgip0u+RLwnIYm+
                bycadzA1s4v0xsZs4FnSUc5MgoiOQunQoFS+9TI7BYDd0zet8BH+bBFNiHqCfMly
                TNKVBvX/TTu6fyBpYg5reguxAOw/ZEFooLn5l9GU1TSiNO3ysAvwBCi6e5Mffab7
                AqvJtfOBBC9eUPzYQO0f+cyqB75iWuiXe7TNItMZ/CCjpDVRbt2CGnwBAkFkMEW2
                pxRHkXN7R92xKGDPHO+K/lvmMQhu51H9elwpNd9l1X32x1ZfsBYKNfGAf7ACZnG3
                jwIDAQAB
                -----END PUBLIC KEY-----
    ${sim_prefix}payeefsp:
      ingress:
        hosts:
          - sim-${sim_prefix}payeefsp.local
      config:
        schemeAdapter:
          secrets:
            jws:
              # The following is an example key and shouldn't be used in production
              privateKey: |-
                -----BEGIN PRIVATE KEY-----
                MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDMu126miewCUCT
                7f49B0SyCPFGzmqGSs9rTPbk1se+BBhqfhsfkZj6cRRfrlg3rme6we0Ib2AF5TQL
                noSBlDAimQcNOHXrqpAY/B0l/mgyUwmfv0NJ3UjZuCFuw3HRrU/oSUfXoDITC+Bi
                120w4FY2B/vPn+1iC/tsaCayneoaV/Sedq7H9+smEnQfGl3p5QJp/B2Ws3Bz1HqI
                IoxLEaO9VMeDHQPvNJn/7g9erqA5vIhmgLS46worOVjdRLH2SECH73qp8Wg0rJ8Y
                eW2kQ8kuY4uHcG3MO6drYrC011U0ZyM90KV7dv2Y0h2FHlpn9s/pmb630m5ELpnB
                T/pYTLcXAgMBAAECggEADqk6Qz3SgBeMMYEWYZ4ZdsW6Ktpm+Xqg/kDy4JywOB9z
                SikBXeeKH3Z6ltwq2BicDV020Wb8Zt+s3vTOmLhDzC544/hPmtKfjWfR2eHX6gaq
                m+8ml+20pQFmb4Kn2MlC/Xzwm/SOXBvPyUmTua95rQExsK12DT0+F4YhLfhYsTh2
                HfkEzdFW4rrd+9ddKG1ZANS4ZaiMyzhtvUWeEBypBtVf+kBk+51t9pLCdjuynb8I
                WylSDhikT3/YQ/3g/Sz3SMp1u4x0GQe9FWYrnPzzp5LnM5fm49v8JWVHUvd0TOi0
                dQV+LYlgSD38YPpi4iKQSh0Zf0EBfbA83GsX2ArJ7QKBgQDmvcA6PqPo0OV/7RKY
                JuziA3TpucL8iVM1i7/Lv6+VkX88uDvEjwLoNAiYcgIm/CMK7WAwA+Dzn4r38EHB
                BKF4KRhP0qQS0KLXsd0tdsmAB0In7+cbKL4ttqNUP98xZAkTLJq9PXqTKN0qtyw4
                SfIsVMjDGoeSdWHObZYbGKICfQKBgQDjJLwolDrVX29V4zVmxQYH5iN+5kwKXHXj
                suHBrW02Oj/GQFh3Xj6JQi3mzTWYhHwhA4pdaQtNYqTaz9Ic/O1VNPic2ovtg+cd
                7sh86qdQ4QZYhN3RT4oX///u6+UK90llh9hEBo3GuZ4X47tuByNtD4SFAlULrkSm
                fW4XaC3gIwKBgGil6HfCDx65F00UnVlKVicPQEf8ivVz5rwjPIJQ1nZ0PYuxVtIH
                tl7PspJJKra5pb7/957vM2fqlOFsIrZCvmS75p3VP7qUyzYeIdzLwgmBwTxRrrP/
                n3kmGx9LtJM29nKuySNIrb3uS5hi6PhCeUYn0cHC13fSKuCvjOOPIXMVAoGBAJg+
                CPdR0tUs8Byq+yH0sIQe1m+5wAG50zJYtUPxD6AnDpO8kQ8A1f19o/JsXJ3rPp+K
                FfVh8LdfhIs8e+H+DLztkizftqXtoLzJTQuc46QsDurJszsVisNnTI1BAvWEpWct
                0+BUXDZ0NuhgNUIb+rygh/v2gjYgCddlfqKlqwntAoGBAM5Kpp5R0G0ioAuqGqfZ
                sHEdLqJMSepgc6c7RC+3G/svtS2IqCfyNfVMM3qV5MY3J7KnAVjGOw2oJbXcPLXa
                uutsVVmPx2d/x2LZdc8dYYcdOQZvrUhmALhAPXM4SRujakxh+Uxi1VOiW+fZL8aW
                uu1pxuWD0gTJxFkp6u4YIAhw
                -----END PRIVATE KEY-----
              publicKey: |-
                -----BEGIN PUBLIC KEY-----
                MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzLtduponsAlAk+3+PQdE
                sgjxRs5qhkrPa0z25NbHvgQYan4bH5GY+nEUX65YN65nusHtCG9gBeU0C56EgZQw
                IpkHDTh166qQGPwdJf5oMlMJn79DSd1I2bghbsNx0a1P6ElH16AyEwvgYtdtMOBW
                Ngf7z5/tYgv7bGgmsp3qGlf0nnaux/frJhJ0Hxpd6eUCafwdlrNwc9R6iCKMSxGj
                vVTHgx0D7zSZ/+4PXq6gObyIZoC0uOsKKzlY3USx9khAh+96qfFoNKyfGHltpEPJ
                LmOLh3BtzDuna2KwtNdVNGcjPdCle3b9mNIdhR5aZ/bP6Zm+t9JuRC6ZwU/6WEy3
                FwIDAQAB
                -----END PUBLIC KEY-----
    ${sim_prefix}testfsp1:
      ingress:
        hosts:
          - sim-${sim_prefix}testfsp1.local
      config:
        schemeAdapter:
          secrets:
            jws:
              # The following is an example key and shouldn't be used in production
              privateKey: |-
                -----BEGIN PRIVATE KEY-----
                MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDZHci4QOmoO2xL
                3p6YjS90Iml5v+WcLFHY3DnHpncaML09EUInaCxLZmrvQ1pRDnJauutn0Nnw+OAJ
                ep+1Qobja4WyJssWk3T0iNC5kIO4CQJ0SMyCb7GJ6zjtqNHOXp685zQKWRAFlUbJ
                uX1ECvo1FMU5iRiMnTFLQw2R9GQOI4S7kED9cpvmgtvJUyMbK8uDJLWDjXHh8D4J
                xvk8Q1qH12qQUnePbXxGz5sbK2tWqusIKNXUWIj5j1iMq5NFGjtT+NwYct8RzthF
                w/ZT2izFDEW+EfFHtbR7vh8BTwHxggnPCNpC+sSH1IlFzYhmyHoR0EBdeZuTiwcr
                KGhfRvJRAgMBAAECggEAJ1r6QMfncsq+sSv71Iw3D1aThvGtZbc06NnWkWWPzkwK
                aXDg7HK6ILrCZHdxfiLfwKmENU/KyZ7bQWycWYdjGwMo+2eDxaZZ+193ckOLVMcx
                TjHJ/FTRuj3MlmvVCBLntDc2nC+Ts2dhKvy4A6b3vrpym6DJtedigZF4er3xiww4
                a9XV7vr5xDEjf4kFWWGtEDuF+4YAEBbmD76cRyF5Hv8eoU0MELCelHqL1jL7W6/5
                sTfbTxRIFO3wmJhW2ZRRyD9EN5lmP9dROxIE4H3tRBihUJVDBA0IXGiE2Z+NjOUJ
                ycbZVT0LMa3XeYKdrhHRGFafWPSPIJCyQOIK33V6BwKBgQD/TjS9sXJ9hXu53bM1
                8/X780kUp66GQF5V+QhMAVW/6BdQ1Fkhv6AuJZl+FujBRszSdl96thILy87qkP+n
                dUDxXn5B2B7MQ1K7uwmKrYW087BfDPa+3R7wKJ4fndIhrqANGy1KCfwhe8GJEzpP
                vlI4JeInrgMXyQgZgj+65zE22wKBgQDZtPu1MD8SJVvUYXgP1u0XqJWZDo5dndI1
                KA7UlefbBqqtZ87EP7zxcTZHaRLuMBPEppH4+K4NsopnZh4rD+bV/NOJ/rI6PMZe
                zIkjLYE+KTgvM7pvwDy+q08fDYnucS4xnHOjLzw8/l4ptJ1uigXkx8PSl94118+5
                h4Ac4ZL1QwKBgQCk/3MggXT/4GvU9I4kuVVpjpLVkYU+aI1PPNH65QX5L9MZvxMX
                t5ObH1uy3LVybAJlpnEQimjhTMeeWzWOkT32gF5SyY0l8AChKUECaiC2kKOU2nkB
                Y0Diby26OzIZ6JSxw7WiWw+iyCuNHmsaLGNQvFML1+9RyO++JKpxbYcl7wKBgBbd
                Vi5CYe1i9REKJ5TqSr5YW1XW3Ibig2hHy77x+4baXWSW6XVdCFgHPt8jHvTbIche
                gig23fjcToLri7GUGvdQdVsh39AT//WG38RNDCzeIWN7uFHyS67uyQGG53yecG6P
                cumplVcGlBcnO/2XC2VqwZtFjfXzs4JVw9PEsS2HAoGANdd6dNf7ETpBgAlesWgS
                73JAElMGkQH42dqejEzMa5CXUCPLQdqHCgxaT4M25c6F8tUhb2qSvV+Cl+zVkqlA
                CpocM6+FV4oYNLIJUtNJj+XLbDkV2XjXYzuzcGlDd9HAv6hzg0zHOhN6ETsxqIx7
                dvV4dxN19eDirp9AVl6k3Ew=
                -----END PRIVATE KEY-----
              publicKey: |-
                -----BEGIN PUBLIC KEY-----
                MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2R3IuEDpqDtsS96emI0v
                dCJpeb/lnCxR2Nw5x6Z3GjC9PRFCJ2gsS2Zq70NaUQ5yWrrrZ9DZ8PjgCXqftUKG
                42uFsibLFpN09IjQuZCDuAkCdEjMgm+xies47ajRzl6evOc0ClkQBZVGybl9RAr6
                NRTFOYkYjJ0xS0MNkfRkDiOEu5BA/XKb5oLbyVMjGyvLgyS1g41x4fA+Ccb5PENa
                h9dqkFJ3j218Rs+bGytrVqrrCCjV1FiI+Y9YjKuTRRo7U/jcGHLfEc7YRcP2U9os
                xQxFvhHxR7W0e74fAU8B8YIJzwjaQvrEh9SJRc2IZsh6EdBAXXmbk4sHKyhoX0by
                UQIDAQAB
                -----END PUBLIC KEY-----
    ${sim_prefix}testfsp2:
      ingress:
        hosts:
          - sim-${sim_prefix}testfsp2.local
      config:
        schemeAdapter:
          secrets:
            jws:
              # The following is an example key and shouldn't be used in production
              privateKey: |-
                -----BEGIN PRIVATE KEY-----
                MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC/uTQyrLSNJcWk
                cP39r5iXl2Nerod3IL4GxID+xEpzMQEpDJbyYQlUgsAqQ6JtbMrt75ImNA9sWOCq
                JRm9Ejn6CAeRIlcRXbwGLawXnwDXmxCPBpKQTa8HAsAvkZ+1KZqjRBKjNJ9D5EXD
                Y36WhEZh51dmlEyxgWvW4DWpq9wGOiPsmo+kgPtRpOBfDAdZtX6Pa6FB+i2pG85D
                kpObHkclr5WM+77EALuaZwv53GZ4GlskkPkuLwHyCAlcYlST4SfpdIiBmRDq8q8L
                0fJqwTpZktdT4kmgKnbCQI81NHHM8TY8aeUjRrhk/b/L/bJpxzgdAYGEQxz5JVP9
                VJloxL4BAgMBAAECggEAGZJlDy5AbcQgOrj0c7IIXw3K6/3I5T+JgQMUNobtbDRY
                1IYQmxcMxMgkw+5d+4zjez11R6GxffDT1HXa20BTWdFY2weSx+bx9XwBhGwJk3hk
                CsOkaFloMz3vbtjUTbhVHxotBzY1WPuZP4CliYNulM/jtTOqEBH0VYZ1ueIJmI3N
                EtSUO1IAYO8SyP4sozLpAIfp4+ftML4HVCiD6aKdVl38S3PX65j1Q3x9Jz3GBSBo
                9UA6cQHRoCMrujeIAeY2uUCevhdm75xoywVFSCpRCguFxIX5GbvISJRL8XFNhDHl
                OY7yHSOJSmnedFh8oRwBDKkoxhwb+nn1wjf4FXdY/QKBgQDgRuqPx2ou25vKOnx1
                G/xvvMLWzB9KF2wqqFP4uNv0dI9qJ7zCf1ifneAv/CEU+JwX5KJknUtanCpWZare
                vlWSH0UItgs0cgEKjKFwYzXIlc06TffkFz+UlGlLXSFD3BR59xmOY/ZwXlgPz4iW
                6TefXvrU+jNGigJVIYEMzBaCLQKBgQDa14VuCOjMa0YtzAd1cQ2jd8dYovnko/J0
                OQtdx9WoEdeKsCJ8cwVJxSOF4739i0h2Bxa/lLI6mn9VuBKddBLThO1+vBCQ1SCi
                rQGYy1JUchy7OTBo1pEMAQ9AsFGXDMg4/uWdM18O9JwDHAIKsj+vGP+NTgVSO5Cq
                lO6QgG+TpQKBgHsKLNDoQ/alAFj3sSPGUL00P2f74AaTxwG4CylesTzxXWSNnF7P
                4lzfDgkFN1j78xaglf7A1IBHQGrZp94/aU6a3RKkXI1PJgcVk9PGedErbcXY1HBL
                2NO4f/Oaig9ig9FNoLWfXanT+FfkMTkphRxnzRBemxbNy+3MTbIpnQeZAoGBAMSF
                yKAAxjZUm2gjEguoI6xJsy3o5WoqxF8Unx1viHHu29YCyGVj0TrnGzhwRTx8KO08
                /nO677bq6TCsJaNaClICzFgEQQgfLLiJjqaM5/lHpH+JIuzyyryx8uWPsSVpaCCu
                3rol2NaQWc39B+RdIA148H0PtH2dWhOlvPrtK8W1AoGBAMza6OkhyCIzSTKVSWuF
                dvIUbj6jjFLuRapusG+JX+B12Upa6Z3lOHe7e0VWq3rgTktnfqf2gO55b+3o30o4
                ww+sGmRdqMTuPCCZx41XT/v0loYm+ik1GAJz1TUFDDtXlouD2QCDJJfZqPIQf29/
                bFt8u+844ddF0+j5r5Q2aXdR
                -----END PRIVATE KEY-----
              publicKey: |-
                -----BEGIN PUBLIC KEY-----
                MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAv7k0Mqy0jSXFpHD9/a+Y
                l5djXq6HdyC+BsSA/sRKczEBKQyW8mEJVILAKkOibWzK7e+SJjQPbFjgqiUZvRI5
                +ggHkSJXEV28Bi2sF58A15sQjwaSkE2vBwLAL5GftSmao0QSozSfQ+RFw2N+loRG
                YedXZpRMsYFr1uA1qavcBjoj7JqPpID7UaTgXwwHWbV+j2uhQfotqRvOQ5KTmx5H
                Ja+VjPu+xAC7mmcL+dxmeBpbJJD5Li8B8ggJXGJUk+En6XSIgZkQ6vKvC9HyasE6
                WZLXU+JJoCp2wkCPNTRxzPE2PGnlI0a4ZP2/y/2yacc4HQGBhEMc+SVT/VSZaMS+
                AQIDAQAB
                -----END PUBLIC KEY-----
    ${sim_prefix}testfsp3:
      ingress:
        hosts:
          - sim-${sim_prefix}testfsp3.local
      config:
        schemeAdapter:
          secrets:
            jws:
              # The following is an example key and shouldn't be used in production
              privateKey: |-
                -----BEGIN PRIVATE KEY-----
                MIIEuwIBADANBgkqhkiG9w0BAQEFAASCBKUwggShAgEAAoIBAQCZKXDVFI703fvK
                SdDnFukWC6EbQipNSg+MzzZvt+E/ynkBO35QK4E9Z3RgOWS74GxMI+K+h6k4+3Z0
                XQJjJAj8dPeserCMnTgThQ76fZ5kDi3YtdoFoxvNVQhTVBGe4soocb/H6XKoUXVH
                qDI4J+KiW4t/bz3OnVRhHIzCdnM5kGFQnXchWgL3ymhueU8m2d6532GqsEbhC9dZ
                D3cbo757UZAn4TZUgiTVSlY07e4nUulUvVV0+pQmjZMwBQNxonBVkFQWuitrbMVh
                ZYEYUL5tB07OAfN/p2LcxumCJ49dGqLvC0VyMsGQkZ3dS9kNKx/sP67xlSl9YeCI
                PN95wxcFAgMBAAECggEAB+EQ4h/89O3e+SGpAPiZTxOUFAkEyTIz1CR6kIstNhEB
                4iVYzykBV2D/3YZ9cOxk/r1N3WgGUggCGlYlPEtO1UJk8g//8jaRNEYWZp582nkR
                mEWjjKWUOR8pu0JYdUTM0Va2CYrayUMGoPXZzNtPiCw5q0C3pycRDdngQMaKgra7
                kj0pOITHpgN4bCPeutKAX514aD+nobJ4UOjcWcAemuoM4ZSl/tqZziXAHi3DjuIL
                jTfeBKae7tViUuQPwxcCNffTAsKAlI0BaD10fb1gzwLZkY4E8LThlIR3Pk6BdPlA
                ab0Gu9rtgIbPJnNFp5QWMVelW+2WF2qWfszu2HloFQKBgQDLhLh8xsP2ioGWLyFl
                JKGDzyNYn+MC3ZWaNttsprl+hBXRMGXfMDlGSJ0WAHYDgjMJIcZqUmPGGchQkwC0
                QnTeRbFLSlzVormqYVxJqrlNs3t0KRqarq1S3aFEPQI/aLBjsuXFlHegdpLJHQW6
                exZvU4+ShS+LMZeu/ywqsUIqgwKBgQDAqG3mFmY3NYZLAA2YWsxU2bQyHgqnK7CJ
                XZxZ+FE+2Xo2EqAMM3fJj5IShlCnjE7ciMt1hyigKTZlKIiO7iOCAiZ0P4XOZuOA
                p3wQEFCjfl7mjTXj75LzWTla+92B1t2tHhYXdd1y3M3yci8UK76MxCZrK/ol4oN5
                UhEHQaeh1wJ/XQNLTbuJ1CN5Fip0GMWlC5ifjuGD3stmlBR+NCn+nNPBJNn5tQdV
                JcoKAQQ062WV7ZaCGBWPg/pEko6cw8Wbo/o2DTLvOrQkJrpYc1KTXe+pfG1Mu2UZ
                0cV47rbzUAeIlggs+x/fjHakn0WkWJXoqviFpXE5SWRg7pmwldJtawKBgQCEj9/+
                n475kgSzenfgSympgJqymWUvHaq8+gJpDampmy6yIiKqAof70qPpxy2b+7kPmbiV
                R8i2W2UoObmsz0LzY9NdzY+eM8F6dsOwsekqdfuKm8Nm8SOl+dCzP/ZsLpIdWkRN
                JDaZoEC8/8BRGsBkT1s4Bux6QN/CDKvW2GAlxQKBgDcTDbSxhmyMjDJr5p1oy4re
                Ju0bMtFyf95B2mqMw781JoKxXHfHNBwtHgku1JHSKtTRCH7w4uoLrN+dDXd68Q6b
                qmJ4KNL+8ac2sJWOyjWP2bB62/Yqx/XcFJXHbfnvSEXRGav+D/aq3xkmRDwa8wqM
                zmVQaekRl4XbZA8+Fvgw
                -----END PRIVATE KEY-----
              publicKey: |-
                -----BEGIN PUBLIC KEY-----
                MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmSlw1RSO9N37yknQ5xbp
                FguhG0IqTUoPjM82b7fhP8p5ATt+UCuBPWd0YDlku+BsTCPivoepOPt2dF0CYyQI
                /HT3rHqwjJ04E4UO+n2eZA4t2LXaBaMbzVUIU1QRnuLKKHG/x+lyqFF1R6gyOCfi
                oluLf289zp1UYRyMwnZzOZBhUJ13IVoC98pobnlPJtneud9hqrBG4QvXWQ93G6O+
                e1GQJ+E2VIIk1UpWNO3uJ1LpVL1VdPqUJo2TMAUDcaJwVZBUFrora2zFYWWBGFC+
                bQdOzgHzf6di3MbpgiePXRqi7wtFcjLBkJGd3UvZDSsf7D+u8ZUpfWHgiDzfecMX
                BQIDAQAB
                -----END PUBLIC KEY-----
    ${sim_prefix}testfsp4:
      ingress:
        hosts:
          - sim-${sim_prefix}testfsp4.local
      config:
        schemeAdapter:
          secrets:
            jws:
              # The following is an example key and shouldn't be used in production
              privateKey: |-
                -----BEGIN PRIVATE KEY-----
                MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDH5Q+uzIdf7yTX
                4A23TTaGSCMU6ieKUmg2qsRJ0/lnk50A0eFQb98ux/XT90oEpqa8dqpla7lic3BK
                XdWoUYI+zmauzepTE3L0IZJB7VzQcPfbZiFG7OrGPAUtxxz4FBbKSA7FJnchIAEs
                blsyu2mQx+zbeajnQS3P+6oqDjdyuT5JyDjna7UFarozx1YXExwyfKsEtIPuMh/U
                L/q80gtWbXA9nA38t7vmdqxhh4PMddHgSEl6KK29yqwHsgpVg/5Yi0ubhbgLQbHm
                6XflBQK05t5AqD2j5h94h/dk9WzoWft8/haxI3OqFoaOOQmHemSs3KJndL+PyzL7
                6JCMlsHBAgMBAAECggEACsA4V3WjG0cEo4KmojLqKY80KdINJdyYQ8Zr76+RpJ81
                DL/8/wNBTOYOw+NzLOxcn9q+/9zrF88vHSTOUrLtjxyxO5oSDf1IC7bJg7e1K/XD
                ct6bkBG6b8Z3HdbtaS9FaYQ2HSbcNeEfhwj5aTFYtGN4SvaQXb2s7dhydrgUhdw1
                1TxXDio728BjRvCOex4H2lmJSflGYwHGJpy1C5Q8upAAMhKMP11598i9Vw7JJI4t
                wZ2vv3w728ApnQzDIiLzKMvNtvoEwQ7PlnSevL6V4sYAnsAmx6ZctEEv632nGPqk
                f5XLlDaczcRDcpAC+nyJKER7T/+emWNFlV0Mj+JMQQKBgQDncR0EzPRWGCDBmH8K
                e2hzzS0RmLb1nouhcFb6EiQR4WTvB8BjAJuf1Brq7gX1b/gGfWkYPS/9AKOI/JzO
                YHACgQmvTaF2WMHcvhb2F/Z96cKIpsD++RIARClv7MSfbTBVcBXbwaboN/B89sGG
                4+07ciy4uCwdK7wJP2gSyy3AsQKBgQDdGwDGppVdcGc4cStlCKoGQnT5owCidqP+
                pLdF5d69pLKaFKFzUh92dUOwLh4qonuOgGGy574JE0oncKn72eie6biEesu+4uuR
                Teu2qrKiHBPDtPlrBZrYnlyE6h9dftAie++bu0UzMSP4WtevxzF0xykELXtlJUx7
                fSjZ7UnWEQKBgQC/qdPPQu/hUG/oAyLKCnLw22xEU0TI2XhmxEKzK0zFpfPRY4j2
                M+2tCZkVDvLOU+CBd2AOG7Xe/qVvb0toOULpP/VGQLLC8DPzW1Rmjmep1Gkug3H2
                dUtr/waV0uzt3h2V05G2gIN5ccHtquePjrfKb/4LJzIZIjvBKMpGLg6AsQKBgAs2
                32cz88d1eAbI1qadNeJzZHN07QdQdSjpOdJ1wkJkJBrkiPvMYoQjlndNH4KSEyo7
                ILluP5k+PTia4kQ/3SiSOiWeBM99uuz3wsjVB5JpUidO+oePFTd/cLndFhIr6GqX
                VqPTb8MU7vodwWrM85k0sMPheqy6o5Jv2q6S9nfBAoGAai34NUJam3rAw+5EF1fI
                9v1AQxFmCX1xPawaFqudGxwod+NtrU5T11O07gDOC9V1ZdDU5btTlEoDgDiy5GNo
                9Bve6yCxr2L7ZaKNccw+yuqTrIzHD4JBpanHjafPCDB+auW0U1lP7Q7TDSzJ42E9
                yq8V8FKKjAQ2hlGoSVfEvG0=
                -----END PRIVATE KEY-----
              publicKey: |-
                -----BEGIN PUBLIC KEY-----
                MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAx+UPrsyHX+8k1+ANt002
                hkgjFOonilJoNqrESdP5Z5OdANHhUG/fLsf10/dKBKamvHaqZWu5YnNwSl3VqFGC
                Ps5mrs3qUxNy9CGSQe1c0HD322YhRuzqxjwFLccc+BQWykgOxSZ3ISABLG5bMrtp
                kMfs23mo50Etz/uqKg43crk+Scg452u1BWq6M8dWFxMcMnyrBLSD7jIf1C/6vNIL
                Vm1wPZwN/Le75nasYYeDzHXR4EhJeiitvcqsB7IKVYP+WItLm4W4C0Gx5ul35QUC
                tObeQKg9o+YfeIf3ZPVs6Fn7fP4WsSNzqhaGjjkJh3pkrNyiZ3S/j8sy++iQjJbB
                wQIDAQAB
                -----END PUBLIC KEY-----
  defaultProbes: &defaultProbes
    livenessProbe:
      enabled: true
      initialDelaySeconds: 3
      periodSeconds: 30
      timeoutSeconds: 10
      successThreshold: 1
      failureThreshold: 3
    readinessProbe:
      enabled: true
      initialDelaySeconds: 3
      periodSeconds: 5
      timeoutSeconds: 5
      successThreshold: 1
      failureThreshold: 3

  ingress:
    # If you're using nginx ingress controller >= v0.22.0 set this to (/|$)(.*). Ensure that you set the `"nginx.ingress.kubernetes.io/rewrite-target": "/$2"`
    # If you're using nginx ingress controller < v0.22.0 set this to an empty string or "/". Ensure that you set the `"nginx.ingress.kubernetes.io/rewrite-target": "/"`
    # This affects the way your rewrite target will work.
    # For more information see "Breaking changes" here:
    # https://github.com/kubernetes/ingress-nginx/blob/master/Changelog.md#0220

    ## https://kubernetes.github.io/ingress-nginx/examples/rewrite/
    # nginx.ingress.kubernetes.io/rewrite-target: '/'
    # nginx.ingress.kubernetes.io/rewrite-target: '/$2'
    ## https://kubernetes.github.io/ingress-nginx/user-guide/multiple-ingress/
    # kubernetes.io/ingress.class: nginx
    ## https://kubernetes.github.io/ingress-nginx/user-guide/tls/#automated-certificate-management-with-kube-lego
    # kubernetes.io/tls-acme: "true""

    ## nginx ingress controller >= v0.22.0
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: '/$2'
    ingressPathRewriteRegex: (/|$)(.*)

    ## nginx ingress controller < v0.22.0
    # annotations:
    #   nginx.ingress.kubernetes.io/rewrite-target: '/'
    # ingressPathRewriteRegex: "/"

  # If you enable JWS validation and intend to communicate via a switch you will almost certainly
  # want to put your switch JWS public key in this array. The name of the property in this object
  # will correspond directly to the name of the signing key (e.g., in the example below,
  # `switch.pem`). Do not include the `.pem` extension, this will be added for you. The scheme
  # adapter will use the FSPIOP-Source header content to identify the relevant signing key to use.
  # The below example assumes your switch will use `FSPIOP-Source: switch`. If instead, for example,
  # your switch is using `FSPIOP-Source: peter` you will need a property `peter` in the following
  # object. Do not add the public keys of your simulators to this object. Instead, put them in
  # `mojaloop-simulator.simulators.$yourSimName.config.schemeAdapter.secrets.jws.publicKey`.
  sharedJWSPubKeys:
    # switch: |-
    #   -----BEGIN PUBLIC KEY-----
    #   blah blah blah
    #   -----END PUBLIC KEY-----

  defaults: &defaults
    # Changes to this object in the parent chart, for example 'mojaloop-simulator.defaults' will be
    # applied to all simulators deployed by this child chart.
    config:
      imagePullSecretName: dock-casa-secret

      cache:

        # These will be supplied directly to the init containers array in the deployment for the
        # scheme adapter. They should look exactly as you'd declare them inside the deployment.
        # Example: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/#init-containers-in-use
        # This init container will have the same environment variables as the main backend container,
        # as specified in .env below.
        # Additionally, the following preset environment variables will be set:
        # SIM_NAME: the name of the simulator as specified in the `mojaloop-simulator` config
        # SIM_SCHEME_ADAPTER_SERVICE_NAME: "sim-$SIM_NAME-scheme-adapter"
        # SIM_BACKEND_SERVICE_NAME: "sim-$SIM_NAME-backend"
        # SIM_CACHE_SERVICE_NAME: "sim-$SIM_NAME-cache"
        initContainers: []
        enabled: true
        image:
          repository: redis
          tag: 5.0.4-alpine
          pullPolicy: IfNotPresent
        <<: *defaultProbes
        livenessProbe:
          enabled: true
          timeoutSeconds: 5
        readinessProbe:
          enabled: true
          timeoutSeconds: 5

      schemeAdapter:
        secrets:
          jws:
            # Use the privKeySecretName field if you would like to supply a JWS private key external
            # to this chart.
            # For example, if you create a private key called `sim-payerfsp-jws-signing-key` external
            # to this chart, you would supply `privKeySecretName: sim-payerfsp-jws-signing-key` here.
            # These fields will take precedence over `privateKey` and `publicKey` below.
            # This field is best supplied per-simulator, however it's here for documentation
            # purposes.
            privKeySecretName: {}
            # TODO: update `privKeySecretName` above to contain both a name and a key in the secret.
            #       Add documentation on usage.
            # privKeySecret: {}
            #   name:
            #   key:
            #
            # The `publicKeyConfigMapName` field allows you to supply a ConfigMap containing JWS public
            # keys external to this release, and have this release reference that ConfigMap to
            # populate JWS public keys. The format of this ConfigMap must be as described for
            # `sharedJWSPubKeys`, a map with one key per FSP/simulator corresponding to the
            # FSPIOP-Source header that will be supplied by that FSP/simulator.
            publicKeyConfigMapName: {}
            # Supply per-simulator private and public keys here:
            privateKey: ''
            publicKey: ''
        image:
          repository: mojaloop/sdk-scheme-adapter
          tag: v11.17.1
          pullPolicy: IfNotPresent
        <<: *defaultProbes

        # These will be supplied directly to the init containers array in the deployment for the
        # scheme adapter. They should look exactly as you'd declare them inside the deployment.
        # Example: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/#init-containers-in-use
        # This init container will have the same environment variables as the main scheme adapter
        # container, as specified in .env below.
        # All init containers will have the same preset environment variables as the backend init
        # container as specified above.
        initContainers: []

        scale:
          enabled: false
          spec:
            minReplicas: 1
            maxReplicas: 10
            metrics:
            - type: Resource
              resource:
                name: cpu
                target:
                  type: Utilization
                  averageUtilization: 80

        env:
          # Ports the scheme adapter listens on. Shouldn't really matter for a user of this chart.
          # You probably shouldn't bother configuring them- it likely won't do you much good. But it
          # won't do any harm, either.
          INBOUND_LISTEN_PORT: 4000
          OUTBOUND_LISTEN_PORT: 4001
          TEST_LISTEN_PORT: 4002

          # Enable mutual TLS authentication. Useful when not running in a secure
          # environment, i.e. when you're running it locally against your own implementation.
          INBOUND_MUTUAL_TLS_ENABLED: false
          OUTBOUND_MUTUAL_TLS_ENABLED: false
          TEST_MUTUAL_TLS_ENABLED: false

          # Enable JWS verification and signing
          VALIDATE_INBOUND_JWS: false
          JWS_SIGN: true

          # applicable only if VALIDATE_INBOUND_JWS is `true`
          # allows disabling of validation on incoming PUT /parties/{idType}/{idValue} requests
          VALIDATE_INBOUND_PUT_PARTIES_JWS: true

          # applicable only if JWS_SIGN is `true`
          # allows disabling of signing on outgoing PUT /parties/{idType}/{idValue} requests
          JWS_SIGN_PUT_PARTIES: true

          # Path to JWS signing key (private key of THIS DFSP)
          # JWS_SIGNING_KEY_PATH: "/jwsSigningKey.key" # TODO: do not configure- will break the chart
          JWS_VERIFICATION_KEYS_DIRECTORY: "/jwsVerificationKeys"

          # Location of certs and key required for TLS. It is possible to configure these- however,
          # at the time of writing, it's not supported by this chart.
          # IN_CA_CERT_PATH: ./secrets/inbound-cacert.pem
          # IN_SERVER_CERT_PATH: ./secrets/inbound-cert.pem
          # IN_SERVER_KEY_PATH: ./secrets/inbound-key.pem

          # OUT_CA_CERT_PATH: ./secrets/outbound-cacert.pem
          # OUT_CLIENT_CERT_PATH: ./secrets/outbound-cert.pem
          # OUT_CLIENT_KEY_PATH: ./secrets/outbound-key.pem

          # TEST_CA_CERT_PATH: ./secrets/test-cacert.pem
          # TEST_CLIENT_CERT_PATH: ./secrets/test-cert.pem
          # TEST_CLIENT_KEY_PATH: ./secrets/test-key.pem

          # The number of space characters by which to indent pretty-printed logs. If set to zero, log events
          # will each be printed on a single line.
          LOG_INDENT: "0"

          # REDIS CACHE CONNECTION
          # CACHE_HOST: "" # Default is parametrised, but it's possible to override this
          CACHE_PORT: 6379

          # Switch or DFSP system under test Mojaloop API endpoint
          # The option 'PEER_ENDPOINT' has no effect if the remaining options 'ALS_ENDPOINT', 'QUOTES_ENDPOINT',
          # 'BULK_QUOTES_ENDPOINT', 'TRANSFERS_ENDPOINT', 'BULK_TRANSFERS_ENDPOINT', 'TRANSACTION_REQUESTS_ENDPOINT' are specified.          # Do not include the protocol, i.e. http.
          PEER_ENDPOINT: "mojaloop-switch"
          # Common Account Lookup System (ALS)
          ALS_ENDPOINT: $release_name-account-lookup-service
          QUOTES_ENDPOINT: $release_name-quoting-service
          TRANSFERS_ENDPOINT: $release_name-ml-api-adapter-service
          BULK_TRANSFERS_ENDPOINT: $release_name-bulk-api-adapter-service
          BULK_QUOTES_ENDPOINT: $release_name-bulk-quoting-service
          TRANSACTION_REQUESTS_ENDPOINT: $release_name-transaction-requests-service

          # This value specifies the endpoint the scheme adapter expects to communicate with the
          # backend on. Do not include the protocol, i.e. http.
          # You're very likely to break the functioning of this chart if you configure the following
          # value. This config item has been copied from the service repo for consistency with that,
          # so that if you come here and find this variable, with this comment, it's less confusing
          # than if you come here and it's missing entirely.
          # BACKEND_ENDPOINT: "localhost:3000"

          # FSPID of this DFSP
          # Commented by default- you're likely to break the chart if you configure this value.
          # DFSP_ID: "mojaloop-sdk"

          # Secret used for generation and verification of secure ILP
          ILP_SECRET: "Quaixohyaesahju3thivuiChai5cahng"

          # expiry period in seconds for quote and transfers issued by the SDK
          EXPIRY_SECONDS: "60"

          # if set to false the SDK will not automatically accept all returned quotes
          # but will halt the transfer after a quote response is received. A further
          # confirmation call will be required to complete the final transfer stage.
          AUTO_ACCEPT_QUOTES: true

          # if set to false the SDK will not automatically accept a resolved party
          # but will halt the transer after a party lookup response is received. A further
          # confirmation call will be required to progress the transfer to quotes state.
          AUTO_ACCEPT_PARTY: true

          # when set to true, when sending money via the outbound API, the SDK will use the value
          # of FSPIOP-Source header from the received quote response as the payeeFsp value in the
          # transfer prepare request body instead of the value received in the payee party lookup.
          # This behaviour should be enabled when the SDK user DFSP is in a forex enabled switch
          # ecosystem and expects quotes and transfers to be rerouted by the switch to forex
          # entities i.e. forex providing DFSPs. Please see the SDK documentation and switch
          # operator documentation for more information on forex use cases.
          USE_QUOTE_SOURCE_FSP_AS_TRANSFER_PAYEE_FSP: false

          # set to true to validate ILP, otherwise false to ignore ILP
          CHECK_ILP: true

          # set to true to enable test features such as request cacheing and retrieval endpoints
          ENABLE_TEST_FEATURES: true

          # set to true to mock WSO2 oauth2 token endpoint
          ENABLE_OAUTH_TOKEN_ENDPOINT: false
          OAUTH_TOKEN_ENDPOINT_CLIENT_KEY: "test-client-key"
          OAUTH_TOKEN_ENDPOINT_CLIENT_SECRET: "test-client-secret"
          OAUTH_TOKEN_ENDPOINT_LISTEN_PORT: "6000"

          # WS02 Bearer Token specific to golden-fsp instance and environment
          WS02_BEARER_TOKEN: "7718fa9b-be13-3fe7-87f0-a12cf1628168"

          # OAuth2 data used to obtain WSO2 bearer token
          OAUTH_TOKEN_ENDPOINT: ""
          OAUTH_CLIENT_KEY: ""
          OAUTH_CLIENT_SECRET: ""
          OAUTH_REFRESH_SECONDS: "3600"

          # Set to true to respect expirity timestamps
          REJECT_EXPIRED_QUOTE_RESPONSES: false
          REJECT_TRANSFERS_ON_EXPIRED_QUOTES: false
          REJECT_EXPIRED_TRANSFER_FULFILS: false

          # Timeout for GET/POST/DELETE - PUT flow processing
          REQUEST_PROCESSING_TIMEOUT_SECONDS: "30"

          # To allow transfer without a previous quote request, set this value to true.
          # The incoming transfer request should consist of an ILP packet and a matching condition in this case.
          # The fulfilment will be generated from the provided ILP packet, and must hash to the provided condition.
          ALLOW_TRANSFER_WITHOUT_QUOTE: false
          RESERVE_NOTIFICATION: false
          RESOURCE_VERSIONS: transfers=1.0,quotes=1.0


      backend:
        image:
          repository: mojaloop/mojaloop-simulator
          tag: v11.4.3
          pullPolicy: IfNotPresent
        <<: *defaultProbes

        # These will be supplied directly to the init containers array in the deployment for the
        # backend. They should look exactly as you'd declare them inside the deployment.
        # Example: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/#init-containers-in-use
        initContainers: []

        # Supply JSON rules here as a string
        # Example:
        # rules: |-
        #   [
        #     {
        #       "ruleId": 1,
        #       .. etc.
        #     }
        #   ]
        rules: |-
          []
        env:
          ##### Section for simulator backend container #####
          # This is the endpoint the backend expects to communicate with the scheme adapter on.
          # Include the protocol, i.e. http.
          # It's not configured by default in this chart as the default value is calculated in a
          # template and configuring it is likely to break communication between the backend and the
          # scheme adapter.
          # OUTBOUND_ENDPOINT: "http://localhost:4001" # within the pod

          # Enable mutual TLS authentication. Useful when the simulator is not running in a managed
          # environment, i.e. when you're running it locally against your own implementation.
          MUTUAL_TLS_ENABLED: false

          # Enable server-only TLS; i.e. serve on HTTPS instead of HTTP.
          HTTPS_ENABLED: false

          # Location of certs and key required for TLS
          CA_CERT_PATH: ./secrets/cacert.pem
          SERVER_CERT_PATH: ./secrets/servercert.pem
          SERVER_KEY_PATH: ./secrets/serverkey.pem

          # The number of space characters by which to indent pretty-printed logs. If set to zero, log events
          # will each be printed on a single line.
          LOG_INDENT: "0"

          # The name of the sqlite log file. This probably doesn't matter much to the user, except that
          # setting :memory: will use an in-memory sqlite db, which will be faster and not consume disk
          # space. However, it will also mean that the logs will be lost once the container is stopped.
          SQLITE_LOG_FILE: ./log.sqlite

          # The DFSPID of this simulator. The simulator will accept any requests routed to
          # FSPIOP-Destination: $SCHEME_NAME. Other requests will be rejected.
          # Not set in this chart as these are calculated in templates. Setting this values is likely
          # to break expected functionality.
          # SCHEME_NAME: golden
          # DFSP_ID: golden

          # The name of the sqlite model database. If you would like to start the simulator with preloaded
          # state you can use a preexisting file. If running in a container, you can mount a sqlite file as a
          # volume in the container to preserve state between runs.
          # Use MODEL_DATABASE: :memory: for an ephemeral in-memory database
          MODEL_DATABASE: ./model.sqlite

          # The simulator can automatically add fees when generating quote responses. Use this
          # variable to control the fee amounts added. e.g. for a transfer of 100 USD a FEE_MULTIPLIER of 0.1
          # reuslts in fees of USD 10 being applied to the quote response
          FEE_MULTIPLIER: "0.05"

          # Specifies the location of a rules file for the simulator backend. Rules can be used to produce
          # specific simulator behaviours in response to incoming requests that match certain conditions.
          # e.g. a rule can be used to trigger NDC errors given transfers between certain limits.
          RULES_FILE: ../rules/rules.json

          # Ports for simulator, report, and test APIs
          SIMULATOR_API_LISTEN_PORT: 3000
          REPORT_API_LISTEN_PORT: 3002
          TEST_API_LISTEN_PORT: 3003

    ingress:
      enabled: true
      path: /
      hosts:
        - mojaloop-simulators.local
      tls: []
      #  - secretName: chart-example-tls
      #    hosts:
      #      - chart-example.local

    resources: {}
      # We usually recommend not to specify default resources and to leave this as a conscious
      # choice for the user. This also increases chances charts run on environments with little
      # resources, such as Minikube. If you do want to specify resources, uncomment the following
      # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
      # limits:
      #  cpu: 100m
      #  memory: 128Mi
      # requests:
      #  cpu: 100m
      #  memory: 128Mi

    ## Pod scheduling preferences.
    ## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
    affinity: {}

    ## Node labels for pod assignment
    ## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector
    nodeSelector: {}

    ## Set toleration for scheduler
    ## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
    tolerations: []