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

# Curl Post call Param 1 is the Full URL, Param 2 is a json file, Param 3 is optional text
# curl_post "$ELASTICSEARCH_URL/demo-rollover-write/_doc" "elasticsearch-config/foo.json" "Fancy text"
# curl_post "$ELASTICSEARCH_URL/demo-rollover-write/_doc" "elasticsearch-config/foo.json"
curl_post () {
	if [ -z "$3" ] ; then
		echo "Calling POST $1"
	else 
	  echo $3
	fi
  curl -XPOST "$1" -u elastic:$ELASTIC_PASSWORD -H 'Content-Type: application/json' -d"@$2" ; echo
}

# Start of the script
echo Run script for Index Split, Shrink and Rollover demo with Elastic $ELASTIC_VERSION

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
echo "#################################"
echo "### Running injection of data ###"
echo "#################################"
echo -ne '\n'

echo "Press [CTRL+C] to stop.."

while true
do
  curl_post "$ELASTICSEARCH_URL/demo-rollover-write/_doc" "elasticsearch-config/foo.json"
  sleep 1
done

echo -ne '\n'


