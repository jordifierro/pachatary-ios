api_key_file="${SRCROOT}/Pachatary/ApiKeys.plist"
key_index="$(awk -F'[<>]' '/<key>/{print $3}' $api_key_file | grep mapboxAccessToken -n | cut -d : -f 1)"
token="$(awk -F'[<>]' '/<string>/{print $3}' $api_key_file | sed "$key_index"'q;d')"
if [ "$token" ]; then
plutil -replace MGLMapboxAccessToken -string $token "$TARGET_BUILD_DIR/$INFOPLIST_PATH"
else
echo 'error: Missing Mapbox access token'
open 'https://www.mapbox.com/studio/account/tokens/'
echo "error: Get an access token from <https://www.mapbox.com/studio/account/tokens/>, then create a new file at $token_file that contains the access token."
exit 1
fi
