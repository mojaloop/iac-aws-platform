source $1/provision_to_backend.sh
# echo HUB_OPERATOR_CONSUMER_AUTH_HEADER $HUB_OPERATOR_CONSUMER_AUTH_HEADER
# echo TOKEN_ENDPOINT $TOKEN_ENDPOINT
export token=$(curl -v -k --location --request POST $TOKEN_ENDPOINT --header "Content-Type: application/x-www-form-urlencoded" --header "Authorization: Basic $HUB_OPERATOR_CONSUMER_AUTH_HEADER" --data-urlencode "grant_type=client_credentials" | jq -r '.access_token') 
# echo token: $token
for filename in $1/*-env.json; do
#    echo token: $token
    newman run $2 --insecure -e $filename --env-var HUB_OPERATOR_BEARER_TOKEN=$token
done