Trafikbaslinje (Traffic Baseline)
1. Inledning och Metod
Denna trafikbaslinje dokumenterar de viktigaste och verifierade trafikflödena i miljön baserat på egna trafikfångster (tcpdump och baseline-3.pcap).

Rapporten fokuserar enbart på verifierbara dataflöden (källa, destination, protokoll, port, riktning och volym/frekvens) utan obekräftade spekulationer om trafikens affärsmässiga syfte.

2. Underlag och Trafikfångster
Huvudsaklig pcap-fil: baseline-3.pcap
Metod för insamling: tcpdump kört på relevanta nätverksgränssnitt (eth0 / eth1).
Analysverktyg: Wireshark och tshark.
3. Verifierade Trafikflöden (Sammanställning)
Flödes-ID	Källa IP	Destination IP	Protokoll	Port	Riktning	Volym / Frekvens (Paket)	Underlag / Källa	Anmärkning / Status
FL-01	172.20.1.137	172.20.1.2	TCP	22 (SSH)	Tvåvägs	146 paket	baseline-3.pcap	Huvudsaklig administreringstrafik mellan elevinstans och jump-server.
FL-02	172.20.1.10	172.20.1.137	TCP	80 (HTTP)	Tvåvägs	Återkommande / Kontroll	baseline-3.pcap / Wireshark	CTF/Kontrollserverns verifieringstrafik mot elevwebbserver.
FL-03	172.20.1.137	172.20.1.10	TCP	80 / 22	Utgående	Låg / Intermittent	baseline-3.pcap	Trafik vid flagginlämning och kontrollkommandon.
4. Sammanfattning av Observationer
Administrativ trafik (SSH): Det dominerande observerade flödet är SSH-kommunikation mellan 172.20.1.137 och Jump-servern 172.20.1.2 (totalt 146 paket i mätperioden).
Kontroll- och verifieringstrafik (HTTP): Inkommande kontrollanrop på port 80 från CTF-servern (172.20.1.10) utgör den primära tjänstetrafiken på elevservern.
Avgränsning: Övriga ströpaket och bakgrundstrafik i baseline-3.pcap har filtrerats bort för att hålla baslinjen ren och fokuserad på regelbunden, verifierad kommunikation.
5. Koppling till Ny Adressplan och Mikrosegmentering
Trafikbaslinjen utgör beslutsunderlag för utformningen av brandväggsregler och mikrosegmentering i målarkitekturen (10.40.0.0/16). Endast flöden som motsvarar verifierad baslinjetrafik kommer att tillåtas i tillståndsbaserade regler (iptables / molnbrandvägg).
