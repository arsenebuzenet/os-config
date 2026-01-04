#!/usr/bin/env bash
set -euo pipefail

QUAD9_IPV4="9.9.9.9,149.112.112.112"
QUAD9_IPV6="2620:fe::fe,2620:fe::9"

echo "Detecting active NetworkManager connection..."

CONN=$(nmcli -t -f NAME,DEVICE,STATE connection show --active | awk -F: '$3=="activated"{print $1; exit}')

if [[ -z "$CONN" ]]; then
  echo "No active NetworkManager connection found"
  exit 1
fi

echo "Active connection: $CONN"

echo "Configuring Quad9 DNS..."

nmcli connection modify "$CONN" \
  ipv4.ignore-auto-dns yes \
  ipv4.dns "$QUAD9_IPV4" \
  ipv6.ignore-auto-dns yes \
  ipv6.dns "$QUAD9_IPV6"

echo "Restarting connection..."
nmcli connection down "$CONN"
nmcli connection up "$CONN"

echo "Quad9 DNS configured successfully"
