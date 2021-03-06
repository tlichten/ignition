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

export PASSWORD=$master_password

echo "Setting fuel admin password"
fuel user change-password --new-pass $PASSWORD
sed -i "s/\"password\": \"admin\"/\"password\": \"$PASSWORD\"/" /etc/fuel/astute.yaml
sed -i "s/OS_PASSWORD: \"\(.*\)\"/OS_PASSWORD: \"$PASSWORD\"/" /root/.config/fuel/fuel_client.yaml
dockerctl shell astute service astute restart
echo "Fuel admin password is $PASSWORD"


for i in $(seq -w 00 $(($NUM_NODES_EXPECTED-1)))
do
  fuel node --node-id 00:$i --name fuelslave-$i
done

fuel env create --name lab --rel 2 --net-segment-type vlan

export MYIP=$(curl -s checkip.amazonaws.com)
export MYHOSTNAME="$MYIP.xip.io"
echo "$MYIP     $MYHOSTNAME" >> /etc/hosts


echo 'Applying settings'
fuel settings --env 1 --download
/usr/bin/env ruby <<-EORUBY
        require 'yaml'
        password = ENV["PASSWORD"]
        myhostname = ENV["MYHOSTNAME"]

        config = YAML.load_file('settings_1.yaml')
        config["editable"]["public_ssl"]["horizon"]["value"] = true
        config["editable"]["public_ssl"]["hostname"]["value"] = myhostname
        config["editable"]["public_ssl"]["services"]["value"] = true
        config["editable"]["common"]["libvirt_type"]["value"] = "kvm"
        config["editable"]["access"]["password"]["value"] = password

        File.open('settings_1.yaml','w') do |h|
                h.write config.to_yaml
        end
EORUBY

fuel settings --env 1 --upload

source ./scenarios/$env_scenario/fuel_deploy.sh

echo 'Starting deploy ...'
fuel deploy-changes --env 1
echo "Environment ready."
echo "Fuel admin password is $PASSWORD"
echo "Horizon available at https://$MYIP.xip.io"
echo "Fuel available at https://$MYIP.xip.io:8443"
