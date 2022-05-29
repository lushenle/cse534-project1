#!/bin/bash
#
function get_iface() {
	ft_local=$(awk '$1=="Local:" {flag=1} flag' <<<"$(</proc/net/fib_trie)")

	for IF in $(ls /sys/class/net/); do
		networks=$(awk '$1=="'$IF'" && $3=="00000000" && $8!="FFFFFFFF" {printf $2 $8 "\n"}' <<<"$(</proc/net/route)")
		for net_hex in $networks; do
			net_dec=$(awk '{gsub(/../, "0x& "); printf "%d.%d.%d.%d\n", $4, $3, $2, $1}' <<<$net_hex)
			mask_dec=$(awk '{gsub(/../, "0x& "); printf "%d.%d.%d.%d\n", $8, $7, $6, $5}' <<<$net_hex)
			awk '/'$net_dec'/{flag=1} /32 host/{flag=0} flag {a=$2} END {print "'$IF'\t" a "\n\t'$mask_dec'\n"}' <<<"$ft_local"
		done
	done
}

function set_masq() {
	local iface=${1}
	iptables -t nat -A POSTROUTING -o ${iface} -j MASQUERADE
}

function set_route() {
	ip route del default
	ip route add default via 172.16.0.1
}

function main() {
	set_route
	iface=$(get_iface | grep '172.16' | awk '{print $1}')
	set_masq ${iface}
}

main
