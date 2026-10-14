## Nätverksinterface
- ip -br addr
	- lo - UNKOWN - 127.0.0.1/8
		- Loopback
	- eth0 - UP - 178.105.70.215/32
	- eth1 - UP - 172.20.1.137/32
-
## Kommando och info
- sudo timeout 120 tcpdump -i any -nn -s 0 -w baseline-3.pcap
- Analyserad i Wireshark
-
- ## Protocol Hierarchy
- UDP
	- Kerberos
		- 1 packet, 24 bytes
	- GPRS Tunneling Protocol
		- 1 packet, 12 bytes
	- EtherCAT frame header > EtherCat datagram(s)
		- 1 packet, 44 bytes
- TCP
	- SSH Protocol
		- 142 packets, 5264 bytes
	- ICMP
		- 3 packets, 304 bytes
- ARP
	- 4 packets, 112 bytes
-
- ## Conversations
- ### IPV4
- -A: 5.226.104.112 -> B: 178.105.70.215
      - 2 packets (1 A -> B, 1 B -> A)
      - 120 bytes (60 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000000 s
  
  - A: 20.127.190.41 -> B: 178.105.70.215
      - 2 packets (1 A -> B, 1 B -> A)
      - 132 bytes (72 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000072 s
  
  - A: 47.89.148.254 -> B: 178.105.70.215
      - 2 packets (1 A -> B, 1 B -> A)
      - 148 bytes (60 bytes A -> B, 88 bytes B -> A)
      - Duration: 0.000055 s
  
  - A: 78.128.113.46 -> B: 178.105.70.215
      - 2 packets (1 A -> B, 1 B -> A)
      - 120 bytes (60 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000026 s
  
  - A: 79.124.49.90 -> B: 178.105.70.215
      - 2 packets (1 A -> B, 1 B -> A)
      - 120 bytes (60 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000047 s
  
  - A: 80.94.92.23 -> B: 178.105.70.215
      - 4 packets (2 A -> B, 2 B -> A)
      - 248 bytes (128 bytes A -> B, 120 bytes B -> A)
      - Duration: 19.414642 s
  
  - A: 85.217.149.72 -> B: 178.105.70.215
      - 4 packets (2 A -> B, 2 B -> A)
      - 264 bytes (144 bytes A -> B, 120 bytes B -> A)
      - Duration: 14.789293 s
  
  - A: 85.239.151.10 -> B: 178.105.70.215
      - 2 packets (1 A -> B, 1 B -> A)
      - 124 bytes (64 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000077 s
  
  - A: 89.37.172.144 -> B: 178.105.70.215
      - 2 packets (1 A -> B, 1 B -> A)
      - 120 bytes (60 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000053 s
  
  - A: 91.196.152.4 -> B: 178.105.70.215
      - 2 packets (1 A -> B, 1 B -> A)
      - 140 bytes (80 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000048 s
  
  - A: 147.185.132.58 -> B: 178.105.70.215
      - 2 packets (1 A -> B, 1 B -> A)
      - 400 bytes (186 bytes A -> B, 214 bytes B -> A)
      - Duration: 0.000029 s
  
  - A: 167.94.145.25 -> B: 178.105.70.215
      - 2 packets (1 A -> B, 1 B -> A)
      - 140 bytes (80 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000023 s
  
  - A: 172.20.1.137 -> B: 172.20.1.2
      - 146 packets (75 A -> B, 71 B -> A)
      - 15776 bytes (8252 bytes A -> B, 7524 bytes B -> A)
      - Duration: 1.371240 s
  
  - A: 176.65.148.199 -> B: 178.105.70.215
      - 2 packets (1 A -> B, 1 B -> A)
      - 120 bytes (60 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000071 s
  
  - A: 185.242.226.9 -> B: 178.105.70.215
      - 2 packets (1 A -> B, 1 B -> A)
      - 124 bytes (64 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000051 s
  
  - A: 193.24.123.120 -> B: 178.105.70.215
      - 2 packets (1 A -> B, 1 B -> A)
      - 120 bytes (60 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000034 s
  
  - A: 194.180.49.127 -> B: 178.105.70.215
      - 2 packets (1 A -> B, 1 B -> A)
      - 120 bytes (60 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000037 s
  
  - A: 207.90.244.12 -> B: 178.105.70.215
      - 2 packets (1 A -> B, 1 B -> A)
      - 124 bytes (64 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000044 s
  
  - A: 216.218.206.118 -> B: 178.105.70.215
      - 2 packets (1 A -> B, 1 B -> A)
      - 216 bytes (94 bytes A -> B, 122 bytes B -> A)
      - Duration: 0.000078 s
  
  - A: 216.219.89.86 -> B: 178.105.70.215
      - 4 packets (2 A -> B, 2 B -> A)
      - 240 bytes (120 bytes A -> B, 120 bytes B -> A)
      - Duration: 58.125281 s
-
- ### TCP
- - A: 5.226.140.112:54783 -> B: 178.105.70.215:119
      - 2 packets (1 A -> B, 1 B -> A)
      - 120 bytes (60 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000042 s
  
  - A: 20.127.190.41:46407 -> B: 178.105.70.215:4443
      - 2 packets (1 A -> B, 1 B -> A)
      - 132 bytes (72 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000072 s
  
  - A: 78.128.113.46:58977 -> B: 178.105.70.215:5686
      - 2 packets (1 A -> B, 1 B -> A)
      - 120 bytes (60 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000026 s
  
  - A: 79.124.49.90:57077 -> B: 178.105.70.215:9253
      - 2 packets (1 A -> B, 1 B -> A)
      - 120 bytes (60 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000047 s
  
  - A: 80.94.92.23:56442 -> B: 178.105.70.215:122
      - 2 packets (1 A -> B, 1 B -> A)
      - 124 bytes (64 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000062 s
  
  - A: 80.94.92.23:56442 -> B: 178.105.70.215:22107
      - 2 packets (1 A -> B, 1 B -> A)
      - 124 bytes (64 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000043 s
  
  - A: 85.217.149.72:46407 -> B: 178.105.70.215:20628
      - 2 packets (1 A -> B, 1 B -> A)
      - 132 bytes (72 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000074 s
  
  - A: 85.217.149.72:46970 -> B: 178.105.70.215:22859
      - 2 packets (1 A -> B, 1 B -> A)
      - 132 bytes (72 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000049 s
  
  - A: 85.239.151.10:41662 -> B: 178.105.70.215:14256
      - 2 packets (1 A -> B, 1 B -> A)
      - 124 bytes (64 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000077 s
  
  - A: 89.37.172.144:28964 -> B: 178.105.70.215:10110
      - 2 packets (1 A -> B, 1 B -> A)
      - 120 bytes (60 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000053 s
  
  - A: 91.196.152.4:42819 -> B: 178.105.70.215:443
      - 2 packets (1 A -> B, 1 B -> A)
      - 140 bytes (80 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000048 s
  
  - A: 167.94.145.25:36303 -> B: 178.105.70.215:8443
      - 2 packets (1 A -> B, 1 B -> A)
      - 140 bytes (80 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000023 s
  
  - A: 172.20.1.137:22 -> B: 172.20.1.2:49468
      - 146 packets (75 A -> B, 71 B -> A)
      - 15776 bytes (8252 bytes A -> B, 7524 bytes B -> A)
      - Duration: 1.371240 s
  
  - A: 176.65.148.199:40817 -> B: 178.105.70.215:443
      - 2 packets (1 A -> B, 1 B -> A)
      - 120 bytes (60 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000071 s
  
  - A: 185.242.226.9:48157 -> B: 178.105.70.215:9242
      - 2 packets (1 A -> B, 1 B -> A)
      - 124 bytes (64 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000051 s
  
  - A: 193.24.123.120:41184 -> B: 178.105.70.215:17030
      - 2 packets (1 A -> B, 1 B -> A)
      - 120 bytes (60 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000034 s
  
  - A: 194.180.49.127:50093 -> B: 178.105.70.215:5121
      - 2 packets (1 A -> B, 1 B -> A)
      - 120 bytes (60 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000037 s
  
  - A: 207.90.244.12:26200 -> B: 178.105.70.215:12519
      - 2 packets (1 A -> B, 1 B -> A)
      - 124 bytes (64 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000044 s
  
  - A: 216.219.89.86:53913 -> B: 178.105.70.215:8763
      - 2 packets (1 A -> B, 1 B -> A)
      - 120 bytes (60 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000055 s
  
  - A: 216.219.89.86:53913 -> B: 178.105.70.215:21976
      - 2 packets (1 A -> B, 1 B -> A)
      - 120 bytes (60 bytes A -> B, 60 bytes B -> A)
      - Duration: 0.000027 s
-
- ### UDP
- - A: 47.89.148.254:60653 -> B: 178.105.70.215:2152
      - 1 packet (1 A -> B, 0 B -> A)
      - 60 bytes (60 bytes A -> B, 0 bytes B -> A)
      - Duration: 0.0 s
  
  - A: 147.185.132.58:53123 -> B: 178.105.70.215:88
      - 1 packet (1 A -> B, 0 B -> A)
      - 186 bytes (186 bytes A -> B, 0 bytes B -> A)
      - Duration: 0.0 s
  
  - A: 216.218.206.118:48490 -> B: 178.105.70.215:34980
      - 1 packet (1 A -> B, 0 B -> A)
      - 94 bytes (94 bytes A -> B, 0 bytes B -> A)
      - Duration: 0.0 s
