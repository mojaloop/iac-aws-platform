[
    {
        "name": "demowallet",
        "matches": ["https://connector.demowallet.${PM4ML_DOMAIN}/inbound/*"],
        "key": {"src": "${DEMOWALLET_KEY_FILENAME}"},
        "cert": {"src": "${DEMOWALLET_CERT_FILENAME}"},
        "passphrase": ""
    },
    {
        "name": "demomfi",
        "matches": ["https://connector.demomfi.${PM4ML_DOMAIN}/inbound/*"],
        "key": {"src": "${DEMOMFI_KEY_FILENAME}"},
        "cert": {"src": "${DEMOMFI_CERT_FILENAME}"},
        "passphrase": ""
    },
	{
        "name": "dfsp1",
        "matches": ["https://connector.pm4mlsenderfsp.${PM4ML_DOMAIN}/inbound/*"],
		"key": {"src": "${DFSP1_KEY_FILENAME}"},
        "cert": {"src": "${DFSP1_CERT_FILENAME}"},
        "passphrase": ""
    },
    {
        "name": "dfsp2",
        "matches": ["https://connector.pm4mlreceiverfsp.${PM4ML_DOMAIN}/inbound/*"],
        "key": {"src": "${DFSP2_KEY_FILENAME}"},
        "cert": {"src": "${DFSP2_CERT_FILENAME}"},
        "passphrase": ""
    }
]