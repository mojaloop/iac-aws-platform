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
        "name": "pm4mlsenderfsp",
        "matches": ["https://pm4mlsenderfsp.${LAB_DOMAIN}/*"],
        "key": {"src": "${PM4MLSENDERFSP_KEY_FILENAME}"},
        "cert": {"src": "${PM4MLSENDERFSP_CERT_FILENAME}"},
        "passphrase": ""
    },
    {
        "name": "pm4mlreceiverfsp",
        "matches": ["https://pm4mlreceiverfsp.${LAB_DOMAIN}/*"],
        "key": {"src": "${PM4MLRECEIVERFSP_KEY_FILENAME}"},
        "cert": {"src": "${PM4MLRECEIVERFSP_CERT_FILENAME}"},
        "passphrase": ""
    }
]