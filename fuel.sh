#!/usr/bin/env bash


echo "Fuel starting up. Awaiting Nailgun server. This can take a few minutes ..."
while ! wget -O /dev/null -o /dev/null --no-proxy 10.20.0.2:8000 &>/dev/null; do :; sleep 5; echo '.'; done

echo "Nailgun available"

echo "Waiting for bootstrap image ..."

while ! egrep "Bootstrap image (.*) has been activated" /var/log/fuel-bootstrap-image-build.log &>/dev/null; do :; sleep 5; echo '.'; done

echo "Bootstrap image available"

iptables -t nat -A POSTROUTING -j MASQUERADE

sleep 120

