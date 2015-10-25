#!/bin/bash
# 20151025 Kirby

which tcpdump >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "FAIL: you must install tcpdump"
    exit 1
fi
which awk >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "FAIL: you must install awk"
    exit 1
fi
which cut >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "FAIL: you must install cut"
    exit 1
fi

sniff=$(tcpdump -c1 -e -nni br-lan "(tcp[tcpflags] & tcp-syn != 0) and (tcp[tcpflags] & tcp-ack == 0) and not dst net 192.168.0.0/16 and not dst net 172.16.0.0/12 and not dst net 10.0.0.0/8 and not dst net 224.0.0.0/4" 2>/dev/null)
# 21:14:27.659021 b8:ac:6f:cb:8c:f7 > 68:05:ca:32:5e:85, ethertype IPv4 (0x0800), length 66: 192.168.1.100.53555 > 216.58.216.68.443: Flags [S], seq 1238118553, win 8192, options [mss 1460,nop,wscale 8,nop,nop,sackOK], length 0
mac=$(echo $sniff |awk '{print $2}')
routermac=$(echo $sniff |awk '{print $4}' |cut -d',' -f1)
ip=$(echo $sniff |sed -e 's/.*length .*: \(.*\) > .*/\1/' |cut -d'.' -f1-4)
echo "mac is $mac"
echo "ip is $ip"

sniff=$(tcpdump -c1 -nni br-lan ether src $routermac and ether dst $mac and arp 2>/dev/null)
# 21:33:32.482541 ARP, Reply 192.168.1.1 is-at 68:05:ca:32:5e:85, length 46
router=$(echo $sniff |sed -e 's/.* Reply \(.*\) is-at .*/\1/')
echo "router is $router"

