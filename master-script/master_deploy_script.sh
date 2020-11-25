
# Create Key Value Maps required by the proxyTemplate

set -e
echo "==== Part 1:- Create KVM Apigee Script ===="

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

echo "==== End of Create KVM Apigee Script ===="

# Download from Github and deploy to your own apigee org

set -e

echo "==== Part 2:- Starting Apigee Deplyment Script ===="


if [ -z "$PROXY_NAME" ]
  then
    echo "Enter the name of the new proxy name:"
    read PROXY_NAME
fi


echo "==== Downloading Proxy from Git Hub Repo ===="
git clone https://github.com/guppratik/apigee-opensource-template
mkdir apiproxy
cd apigee-opensource-template/apiproxy
cp -r * ../../apiproxy/
cd ../..
zip -r "$PROXY_NAME".zip apiproxy


# Upload New Proxy
echo "====Uploading new proxy $PROXY_NAME ===="
uploadResponse=$(curl -X POST -u "${APIGEE_USER}:${APIGEE_PW}" -F "file=@${PROXY_NAME}.zip" "https://api.enterprise.apigee.com/v1/organizations/${APIGEE_ORG}/apis?action=import&name=${PROXY_NAME}")
revision=$( jq -r  '.revision' <<< "${uploadResponse}" )
echo ""
echo "====Upload complete - revision: ${revision}===="
# Deploy uploaded proxy

# Delete the folders that were created while the script was running
rm -rf apiproxy/ "$PROXY_NAME".zip apigee-opensource-template

echo "==== Part 3:- Create product , developer and App to access the API template ===="
#Create product , developer and App to access the API template
set -e

echo "==== 3.1 Creating Product ===="

if [ -z "$PRODUCT_NAME" ]
  then
    echo "Enter PRODUCT_NAME :"
    read PRODUCT_NAME
fi

echo "==== Creating product: ${PRODUCT_NAME} ===="
curl -X POST -u "${APIGEE_USER}:${APIGEE_PW}" --header "Content-Type: application/json" -d "{
  \"name\" : \"${PRODUCT_NAME}\",
  \"displayName\": \"${PRODUCT_NAME}\",
  \"approvalType\": \"auto\",
  \"attributes\": [],
  \"description\": \"${PRODUCT_NAME}\",
  \"apiResources\": [ \"/\", \"/**\"],
  \"environments\": [ \"${APIGEE_ENV}\"],
  \"proxies\": [\"${PROXY_NAME}\"],
  \"quota\": \"20\",
  \"quotaInterval\": \"1\",
  \"quotaTimeUnit\": \"minute\",
    \"scopes\": []
}" "https://api.enterprise.apigee.com/v1/organizations/$APIGEE_ORG/apiproducts"

echo ""
echo "==== Product created ===="
# Create Developer
echo "==== 3.2 Creating developer ===="
if [ -z "${DEVELOPER_EMAIL}" ]
  then
    echo "Enter developer email :"
    read DEVELOPER_EMAIL
fi
if [ -z "${FIRST_NAME}" ]
  then
    echo "Enter developer first name :"
    read FIRST_NAME
fi
if [ -z "${LAST_NAME}" ]
  then
    echo "Enter developer last name :"
    read LAST_NAME
fi

curl -X POST -u "${APIGEE_USER}:${APIGEE_PW}"  --header "Content-Type: application/json" -d "{
 \"email\" : \"${DEVELOPER_EMAIL}\",
 \"firstName\" : \"${FIRST_NAME}\",
 \"lastName\" : \"${LAST_NAME}\",
 \"userName\" : \"${DEVELOPER_EMAIL}\",
 \"attributes\" : []
}" "https://api.enterprise.apigee.com/v1/organizations/$APIGEE_ORG/developers"
echo ""
echo "==== Developer created ===="

# Create App
echo "==== 3.3 Creating app: ===="
if [ -z "${APP_NAME}" ]
  then
    echo "Enter app name :"
    read APP_NAME
fi

curl -X POST -u "${APIGEE_USER}:${APIGEE_PW}" --header "Content-Type: application/json" -d "{
 \"name\" : \"${APP_NAME}\",
 \"apiProducts\": [ \"${PRODUCT_NAME}\"],
 \"keyExpiresIn\" : -1,
 \"attributes\" : [],
 \"scopes\" : []
}" "https://api.enterprise.apigee.com/v1/organizations/$APIGEE_ORG/developers/$DEVELOPER_EMAIL/apps"

echo "==== App Created ===="

echo "==== Copy the consumerKey from the result to call the Proxy Template API ===="
