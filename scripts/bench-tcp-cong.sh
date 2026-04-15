#!/bin/bash

# Simulate 20ms RTT + 0.5% loss + 2ms jitter
sudo tc qdisc replace dev lo root netem delay 10ms 2ms loss 0.5%

# Run both
sudo sysctl -w net.ipv4.tcp_congestion_control=bbr
iperf3 -c 127.0.0.1 -t 5 -P 4 2>&1 | tail -5

sudo sysctl -w net.ipv4.tcp_congestion_control=cubic
iperf3 -c 127.0.0.1 -t 5 -P 4 2>&1 | tail -5

# Cleanup
sudo tc qdisc del dev lo root
