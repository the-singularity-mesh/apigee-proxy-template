set -e

echo "====Starting Apigee Script===="
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
if [ -z "$PRODUCT_NAME" ]
  then
    echo "Enter PRODUCT_NAME :"
    read PRODUCT_NAME
fi

echo "====Creating product: ${PRODUCT_NAME}===="
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
echo "====Product created===="
# Create Developer
echo "====Creating developer===="
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
echo "====Developer created===="

# Create App
echo "====Creating app:===="
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

echo "====App Created===="
