set -e

echo "====Starting Apigee Deplyment Script===="

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
if [ -z "$PROXY_NAME" ]
  then
    echo "Enter proxy name:"
    read PROXY_NAME
fi
if [ -z "$APIGEE_ENV" ]
  then
    echo "Enter APIGEE_ENV name:"
    read APIGEE_ENV
fi


echo "====Download Proxy from Git Hub Repo ===="
git clone https://github.com/guppratik/apigee-opensource-template
mkdir apiproxy
cd apigee-opensource-template/apiproxy
cp -r * ../../apiproxy/
cd ../..
zip -r "$PROXY_NAME".zip apiproxy

echo "$APIGEE_ENV"
# Upload New Proxy
echo "====Uploading new proxy 'New Proxy'===="
uploadResponse=$(curl -X POST -u "${APIGEE_USER}:${APIGEE_PW}" -F "file=@${PROXY_NAME}.zip" "https://api.enterprise.apigee.com/v1/organizations/${APIGEE_ORG}/apis?action=import&name=${PROXY_NAME}")
revision=$( jq -r  '.revision' <<< "${uploadResponse}" )
echo ""
echo "====Upload complete - revision: ${revision}===="
# Deploy uploaded proxy

# Delete the folders that were created while the script was running
rm -rf apiproxy/ "$PROXY_NAME".zip apigee-opensource-template
