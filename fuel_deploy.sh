#!/usr/bin/env bash

NUM_NODES_EXPECTED=$1

. parse_yaml.sh

eval $(parse_yaml env.yaml)

NUM_NODES_DISCOVERED=0
while [ $NUM_NODES_DISCOVERED -ne $NUM_NODES_EXPECTED ]; do
  NUM_NODES_DISCOVERED=$(fuel node | grep discover | wc -l) 2>&1
  echo "Discovered $NUM_NODES_DISCOVERED/$NUM_NODES_EXPECTED node(s) so far"
  sleep 5
done

if [ "$env_genpassword" = true ]; then
  echo "Setting fuel admin password"
  PASSWORD=$(date +%s | sha256sum | base64 | head -c 8)
  fuel user change-password --new-pass $PASSWORD
  sed -i "s/\"password\": \"admin\"/\"password\": \"$PASSWORD\"/" /etc/fuel/astute.yaml
  sed -i "s/KEYSTONE_PASS: \"\(.*\)\"/KEYSTONE_PASS: \"$PASSWORD\"/" /root/.config/fuel/fuel_client.yaml
  dockerctl shell astute service astute restart
  echo "Fuel admin password is $PASSWORD"
fi

for i in $(seq -w 01 $NUM_NODES_EXPECTED)
do
 fuel node --node-id 00:$i --name fuelslave-$i 
done

echo "Environment ready."
