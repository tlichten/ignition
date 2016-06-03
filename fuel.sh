#!/usr/bin/env bash

echo "Fuel starting up. Awaiting Nailgun server. This can take a few minutes ..."
while ! wget -O /dev/null -o /dev/null --no-proxy 10.20.0.2:8000 &>/dev/null; do :; sleep 5; echo '.'; done

echo "Nailgun available"

echo "Waiting for bootstrap image ..."

while ! egrep "Bootstrap image (.*) has been activated" /var/log/fuel-bootstrap-image-build.log &>/dev/null; do :; sleep 5; echo '.'; done

echo "Bootstrap image available"
echo "Setting fuel admin password"
PASSWORD=$(date +%s | sha256sum | base64 | head -c 8)
fuel user change-password --new-pass $PASSWORD
sed -i "s/\"password\": \"admin\"/\"password\": \"$PASSWORD\"/" /etc/fuel/astute.yaml
sed -i "s/KEYSTONE_PASS: \"\(.*\)\"/KEYSTONE_PASS: \"$PASSWORD\"/" /root/.config/fuel/fuel_client.yaml 
dockerctl shell astute service astute restart

iptables -t nat -A POSTROUTING -j MASQUERADE

sleep 120

echo "Environment ready. Fuel admin password is $PASSWORD"

