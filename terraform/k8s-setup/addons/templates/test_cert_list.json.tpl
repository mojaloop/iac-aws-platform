[
    {
        "name": "payerfsp",
        "matches": ["https://payerfsp.${LAB_DOMAIN}/*"],
        "key": {"src": "${PAYERFSP_KEY_FILENAME}"},
        "cert": {"src": "${PAYERFSP_CERT_FILENAME}"},
        "passphrase": ""
    },
    {
        "name": "payeefsp",
        "matches": ["https://payeefsp.${LAB_DOMAIN}/*"],
        "key": {"src": "${PAYEEFSP_KEY_FILENAME}"},
        "cert": {"src": "${PAYEEFSP_CERT_FILENAME}"},
        "passphrase": ""
    },
	{
        "name": "testfsp1",
        "matches": ["https://testfsp1.${LAB_DOMAIN}/*"],
		"key": {"src": "${TESTFSP1_KEY_FILENAME}"},
        "cert": {"src": "${TESTFSP1_CERT_FILENAME}"},
        "passphrase": ""
    },
    {
        "name": "testfsp2",
        "matches": ["https://testfsp2.${LAB_DOMAIN}/*"],
        "key": {"src": "${TESTFSP2_KEY_FILENAME}"},
        "cert": {"src": "${TESTFSP2_CERT_FILENAME}"},
        "passphrase": ""
    },
	{
        "name": "testfsp3",
        "matches": ["https://testfsp3.${LAB_DOMAIN}/*"],
        "key": {"src": "${TESTFSP3_KEY_FILENAME}"},
        "cert": {"src": "${TESTFSP3_CERT_FILENAME}"},
        "passphrase": ""
    },
    {
        "name": "testfsp4",
        "matches": ["https://testfsp4.${LAB_DOMAIN}/*"],
        "key": {"src": "${TESTFSP4_KEY_FILENAME}"},
        "cert": {"src": "${TESTFSP4_CERT_FILENAME}"},
        "passphrase": ""
    },
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