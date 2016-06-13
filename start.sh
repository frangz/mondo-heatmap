#!/bin/sh

set -e

trap 'kill $(jobs -p)' EXIT

ACCOUNT_ID=
ACCESS_TOKEN=

if [ -z "$ACCOUNT_ID" ] || [ -z "$ACCESS_TOKEN" ]; then
    echo "Go to https://developers.getmondo.co.uk to get your account ID and access token and add them to this script."
    exit 1
fi 

echo "Downloading data from Mondo..."

curl -s "https://api.getmondo.co.uk/transactions?expand\[\]=merchant&account_id=$ACCOUNT_ID" -H "authorization: Bearer $ACCESS_TOKEN" > transactions.json

cat transactions.json | jq '[.transactions | .[] | select(.merchant != null) | select(.merchant.address != null) | select(.merchant.address.latitude != null) | select(.merchant.address.longitude > -0.2 and .merchant.address.longitude < 0.2) | { "lon": .merchant.address.longitude, "lat": .merchant.address.latitude , "weight": .amount, "category": .merchant.category }]' > heatmap.json

python -m SimpleHTTPServer 8000 &

open http://localhost:8000/index.html

for job in `jobs -p`
do
    wait $job
done
