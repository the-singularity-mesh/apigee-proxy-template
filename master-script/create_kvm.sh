set -e

echo "====Starting Create KVM Apigee Script===="
if [ -z "$APIGEE_ORG" ]
  then
    echo "Enter orgname:"
    read APIGEE_ORG
fi
if [ -z "$APIGEE_USER" ]
  then
    echo "Enter username:"
    read APIGEE_USER
fi
if [ -z "$APIGEE_PW" ]
  then
    echo "Enter password:"
    read -s APIGEE_PW
fi
if [ -z "$APIGEE_ENV" ]
  then
    echo "Enter APIGEE_ENV name:"
    read APIGEE_ENV
fi

curl -X POST -u "${APIGEE_USER}:${APIGEE_PW}" "https://api.enterprise.apigee.com/v1/organizations/${APIGEE_ORG}/environments/${APIGEE_ENV}/keyvaluemaps" \
--header 'Accept: application/json' \
--header 'Content-Type: application/json' \
--data-raw '{
  "encrypted": false,
  "entry": [
    {
      "name": "ALLOWED_CORS_METHODS",
      "value": "GET,POST,OPTIONS,PUT,DELETE"
    },
    {
      "name": "ALLOWED_CORS_DOMAINS",
      "value": "https://apigee.com,https://guppratik-56916-eval-pghipsterapiportal.apigee.io,https://apigee.com"
    },
    {
      "name": "ALLOWED_CORS_HEADERS",
      "value": "Content-Type"
    },
    {
      "name": "CLIENT_IP_WHITE_LIST",
      "value": "10.10.10.10"
    },
    {
      "name": "UnderMaintenanceStateConfig",
      "value": " {\n \t\"proxyUnderMaintenance\": false,\n \t\"proxyUnderMaintenanceResponseCode\": 503,\n \t\"proxyUnderMaintenanceResponsePayload\": \"{\\\"message\\\": \\\"Service is Under Maintenance.. \\\"}\",\n \t\"endpointsUndermaintenance\": [{\n \t\t\"pathSuffixRE\": \"^/products123/*$\",\n \t\t\"httpVerb\": \"GET\",\n \t\t\"httpResponseCode\": 503,\n \t\t\"responseContent\": \"{\\\"message\\\": \\\"This service in under maintenance, will be back soon.. \\\"}\"\n \t}]\n }"
    }
  ],
  "name": "proxyTemplate-config"
}'
