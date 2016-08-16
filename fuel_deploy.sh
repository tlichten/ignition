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
export PASSWORD= 
if [ "$env_genpassword" = true ]; then
  echo "Setting fuel admin password"
  PASSWORD=$(date +%s | sha256sum | base64 | head -c 8)
  fuel user change-password --new-pass $PASSWORD
  sed -i "s/\"password\": \"admin\"/\"password\": \"$PASSWORD\"/" /etc/fuel/astute.yaml
  sed -i "s/OS_PASSWORD: \"\(.*\)\"/OS_PASSWORD: \"$PASSWORD\"/" /root/.config/fuel/fuel_client.yaml
  dockerctl shell astute service astute restart
  echo "Fuel admin password is $PASSWORD"
fi

for i in $(seq -w 00 $(($NUM_NODES_EXPECTED-1)))
do
  fuel node --node-id 00:$i --name fuelslave-$i 
done

fuel env create --name lab --rel 2 --net-segment-type vlan

fuel node set --node 00:00 --role controller --env 1
fuel node set --node 00:01 --role compute --env 1

echo 'Applying settings'
fuel settings --env 1 --download
export MYIP=$(curl -s 4.ifcfg.me)
export MYHOSTNAME="$MYIP.xip.io"
echo "$MYIP     $MYHOSTNAME" >> /etc/hosts

/usr/bin/env ruby <<-EORUBY
  require 'yaml'
        password = ENV["PASSWORD"]
        myhostname = ENV["MYHOSTNAME"]
        
        config = YAML.load_file('settings_1.yaml')
        config["editable"]["public_ssl"]["horizon"]["value"] = true
        config["editable"]["public_ssl"]["hostname"]["value"] = myhostname
        config["editable"]["public_ssl"]["services"]["value"] = true
        config["editable"]["common"]["libvirt_type"]["value"] = "kvm"
        config["editable"]["additional_components"]["murano"]["value"] = true
        config["editable"]["access"]["password"]["value"] = password
        
        File.open('settings_1.yaml','w') do |h|
                h.write config.to_yaml
        end
EORUBY

fuel settings --env 1 --upload

echo 'Starting deploy ...'
fuel deploy-changes --env 1
echo "Environment ready."
if [ "$env_genpassword" = true ]; then
  echo "Fuel admin password is $PASSWORD"
fi
echo "Horizon available at http://instance-public-ip."
echo "Fuel available at https://instance-public-ip:8443"

