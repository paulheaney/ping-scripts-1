#!/bin/sh

# sample script to manage OAuth clients

ADM_USER=administrator
ADM_PWD=2Federate
PF_API=https://localhost:9999/pf-admin-api/v1

FLAGS="-k -s -u \"${ADM_USER}:${ADM_PWD}\" -H \"X-XSRF-Header: pingfed\""

case $1 in

	list)
		echo ${FLAGS} | xargs curl ${PF_API}/oauth/clients
		;;

	get)
		echo ${FLAGS} | xargs curl ${PF_API}/oauth/clients/${2}
		;;

	delete)
		echo ${FLAGS} | xargs curl -X DELETE ${PF_API}/oauth/clients/${2}
		;;

	create-cc)
		#"redirectUris": [ "https://localhost:9031/OAuthPlayground/case1A-callback.jsp" ],	
		JSON_DATA=`cat <<JSON
{
  "clientId": "${2}",
  "defaultAccessTokenManagerRef": {
	"id": "default",
 "location": "${PF_API}/oauth/accessTokenManagers/descriptors/org.sourceid.oauth20.token.plugin.impl.ReferenceBearerAccessTokenManagementPlugin"
  },
  "grantTypes": [
    "CLIENT_CREDENTIALS"
  ],
  "name": "${2}",
  "clientAuth": {
    "type": "CERTIFICATE",
    "clientCertIssuerDn": "CN=localhost, OU=Development, O=PingIdentity, L=Denver, ST=CO, C=US",
    "clientCertSubjectDn": "CN=${2}"
  }
}
JSON`
		echo ${FLAGS} | xargs curl -H "Content-Type: application/json" --data-binary "${JSON_DATA}" ${PF_API}/oauth/clients
		;;

	create-ac)
		JSON_DATA=`cat <<JSON
   {
      "clientId": "${2}",
      "redirectUris": [
        "https://localhost:9031/OAuthPlayground/case1-callback.jsp"
      ],
      "grantTypes": [
        "AUTHORIZATION_CODE",
        "REFRESH_TOKEN"
      ],
      "name": "Authorization Code Client ${2}",
      "description": "",
      "logoUrl": "",
      "refreshRolling": "SERVER_DEFAULT",
      "persistentGrantExpirationType": "SERVER_DEFAULT",
      "persistentGrantExpirationTime": 0,
      "persistentGrantExpirationTimeUnit": "DAYS",
      "bypassApprovalPage": false,
      "restrictScopes": false,
      "restrictedScopes": [],
      "validateUsingAllEligibleAtms": false,
      "oidcPolicy": {
        "grantAccessSessionRevocationApi": false,
        "pingAccessLogoutCapable": false
      },
      "clientAuth": {
        "type": "SECRET",
        "secret": "2Federate"
      }
    }
JSON`
		echo ${FLAGS} | xargs curl -H "Content-Type: application/json" --data-binary "${JSON_DATA}" ${PF_API}/oauth/clients        
		;;

	update-client-secret)	
		JSON_DATA=`echo ${FLAGS} | xargs curl ${PF_API}/oauth/clients/${2} | jq \
		". | del(.clientAuth.encryptedSecret) | .clientAuth.secret = \"${3}\" \
		"`
		echo ${FLAGS} | xargs curl -v -H "Content-Type: application/json" -X PUT --data-binary "${JSON_DATA}" ${PF_API}/oauth/clients/${2}		
		;;

	*)
		echo "Usage: $0 [ list | get <id> | delete <id> | create-cc <id> | create-ac <id> | update-client-secret <id> <secret>"
		;;		
esac
