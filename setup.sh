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

# Curl Delete call Param 1 is the URL, Param 2 is optional text
curl_delete () {
	if [ -z "$2" ] ; then
		echo "Calling DELETE /$1"
	else 
	  echo $2
	fi
  curl -XDELETE "$ELASTICSEARCH_URL/$1" -u elastic:$ELASTIC_PASSWORD ; echo
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

curl_delete "kibana_sample_data_ecommerce*"
curl_delete "demo-rollover*"
curl_delete "_index_template/demo-rollover"

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


