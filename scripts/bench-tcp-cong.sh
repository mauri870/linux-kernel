#!/bin/bash
set -euo pipefail

cleanup() {
	sudo tc qdisc del dev lo root 2>/dev/null || true
	[[ -n "${SERVER_PID:-}" ]] && kill "$SERVER_PID" 2>/dev/null || true
	sudo sysctl -w net.ipv4.tcp_congestion_control="$ORIG_CC" >/dev/null
}
trap cleanup EXIT

ORIG_CC=$(sysctl -n net.ipv4.tcp_congestion_control)

# Simulate 20ms RTT + 0.5% loss + 2ms jitter
sudo tc qdisc replace dev lo root netem delay 10ms 2ms loss 0.5%

# Start iperf3 server in background
iperf3 -s -D --pidfile /tmp/iperf3-bench.pid
SERVER_PID=$(cat /tmp/iperf3-bench.pid)
sleep 0.5

for cc in bbr cubic; do
	sudo sysctl -w net.ipv4.tcp_congestion_control="$cc" >/dev/null
	echo "=== $cc ==="
	iperf3 -c 127.0.0.1 -t 5 -P 4 2>&1 | tail -5
done
