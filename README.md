ip_swap
=======

Script to change the network binding of Linux systems by swapping eth0 configs

	If changing to a static IP, it will prompt for new IP and netmask unless you add them to ifcfg_eth0.template with "IPADDR=" and "NETMASK="

OPTIONS:
   -d
      Change to DHCP...
   -p
      Run the prompt to choose between DHCP and static IPs
       - This is also called when used without flags
   -s
      Change to a static IP...
       - Unless specified in ifcfg_eth0.template, you will be prompted for a new IPADDR and NETMASK
