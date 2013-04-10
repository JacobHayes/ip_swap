function check_connection
{
   ping -c 1 -t 60  www.google.com > /dev/null

   if (( `echo $?` == 0 ))
   then
      echo ""
      echo "Connected to the internet..."

      connected="y"
   else
      connected="n"
   fi
}

echo "Would you like to connect to DHCP or run with a static ip?"
echo "NOTE: Swapping may change the connected IP, so ssh clients will be dropped!"

check_connection

echo ""
echo "D=DHCP    S=static"
printf "[D]/S: "
read reply
reply=${reply:-D}

cur_ip=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo ""
echo "Current: IPADDR=\"$cur_ip\""

if [[ $reply == "D" || $reply == "d"  ]]
then
   cp ifcfg-eth0_dhcp /etc/sysconfig/network-scripts/ifcfg-eth0

   echo "New IP is unknown. Check you DHCP server or try ip_tester.sh to check for hosts."
elif [[ $reply == "S" || $reply == "s"  ]]
then
   cp ifcfg-eth0_static /etc/sysconfig/network-scripts/ifcfg-eth0

   new_ip=`cat ifcfg-eth0_static | grep 'IPADDR='`
   echo "New:  $new_ip"
else
   echo "Unknown input. Rerun."
   exit 1
fi

service network restart

echo ""
echo "Done!"
