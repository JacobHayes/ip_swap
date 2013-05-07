ip_swap
=======

Script to change the network binding of Linux systems by swapping eth0 configs

```
OPTIONS:
   -d
      Change to DHCP...
   -p
      Run the prompt to choose between DHCP and static IPs
       - This is also called when used without flags
   -s
      Change to a static IP...
       - Unless specified in ifcfg_eth0.template, you will be prompted for a new GATEWAY, IPADDR, and NETMASK
```
