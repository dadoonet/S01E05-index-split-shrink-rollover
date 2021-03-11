source .env.sh

# Utility functions
check_service () {
	echo -ne '\n'
	echo $1 $ELASTIC_VERSION must be available on $2
	echo -ne "Waiting for $1"

	until curl -u elastic:$ELASTIC_PASSWORD -s "$2" | grep "$3" > /dev/null; do
		  sleep 1
			echo -ne '.'
	done

	echo -ne '\n'
	echo $1 is now up.
}

# Curl Delete call Param 1 is the Full URL, Param 2 is optional text
# curl_delete "$ELASTICSEARCH_URL/foo*" "Fancy text"
# curl_delete "$ELASTICSEARCH_URL/foo*"
curl_delete () {
	if [ -z "$2" ] ; then
		echo "Calling DELETE $1"
	else 
	  echo $2
	fi
  curl -XDELETE "$1" -u elastic:$ELASTIC_PASSWORD -H 'kbn-xsrf: true' ; echo
}

# Curl Post call Param 1 is the Full URL, Param 2 is a json file, Param 3 is optional text
# 
curl_post () {
	if [ -z "$3" ] ; then
		echo "Calling POST $1"
	else 
	  echo $3
	fi
  curl -XPOST "$1" -u elastic:$ELASTIC_PASSWORD -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d"@$2" ; echo
}

# Curl Post call Param 1 is the Full URL, Param 2 is a json file, Param 3 is optional text
# 
curl_post_form () {
	if [ -z "$3" ] ; then
		echo "Calling POST FORM $1"
	else 
	  echo $3
	fi
  curl -XPOST "$1" -u elastic:$ELASTIC_PASSWORD -H 'kbn-xsrf: true' --form file="@$2" ; echo
}

# Curl Put call Param 1 is the Full URL, Param 2 is a json file, Param 3 is optional text
# 
curl_put () {
	if [ -z "$3" ] ; then
		echo "Calling PUT $1"
	else 
	  echo $3
	fi
  curl -XPUT "$1" -u elastic:$ELASTIC_PASSWORD -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d"@$2" ; echo
}

# Curl Get call Param 1 is the Full URL, Param 2 is optional text
# 
curl_get () {
	if [ -z "$2" ] ; then
		echo "Calling GET $1"
	else 
	  echo $2
	fi
  curl -XGET "$1" -u elastic:$ELASTIC_PASSWORD ; echo
}

# Start of the script
echo Installation script for Index Split, Shrink and Rollover demo with Elastic $ELASTIC_VERSION

echo "##################"
echo "### Pre-checks ###"
echo "##################"

if [ -z "$CLOUD_ID" ] ; then
	echo "We are running a local demo. If you did not start Elastic yet, please run:"
	echo "docker-compose up"
fi

check_service "Elasticsearch" "$ELASTICSEARCH_URL" "\"number\" : \"$ELASTIC_VERSION\""
check_service "Kibana" "$KIBANA_URL/app/home#/" "<title>Elastic</title>"

echo -ne '\n'
echo "################################"
echo "### Configure Cloud Services ###"
echo "################################"
echo -ne '\n'

curl_delete "$ELASTICSEARCH_URL/kibana_sample_data_ecommerce*"
curl_delete "$ELASTICSEARCH_URL/demo-rollover*"
curl_delete "$ELASTICSEARCH_URL/_index_template/demo-rollover"

echo -ne '\n'
echo "#############################"
echo "### Install Canvas Slides ###"
echo "#############################"
echo -ne '\n'

curl_post_form "$KIBANA_URL/api/saved_objects/_import?overwrite=true" "kibana-config/canvas.ndjson"

echo -ne '\n'
echo "#####################"
echo "### Demo is ready ###"
echo "#####################"
echo -ne '\n'

# open $KIBANA_URL/app/management/data/index_management/templates
# open $KIBANA_URL/app/dev_tools/

# echo "If not yet there, paste the following script in Dev Tools:"
# cat elasticsearch-config/devtools-script.json
echo -ne '\n'


