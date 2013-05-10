function CHECK_CONNECTION
{
   echo ""

   ping -c 1 -t 60  www.google.com &> /dev/null

   if (( `echo $?` == 0 ))
   then
      echo "Connected to the internet..."
   else
      echo "Not connected to the internet..."
   fi
}

function DHCP
{
   cp ifcfg-eth0.template $ifcfg_file

   echo "BOOTPROTO=\"dhcp\"" >> $ifcfg_file

   echo ""
   echo "New IP is unknown. Check you DHCP server or try ip_tester.sh to check for hosts."
}

function PROMPT
{
   CHECK_CONNECTION

   cur_ip=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
   echo ""
   echo "Current: IPADDR=\"$cur_ip\""

   echo "Would you like to connect to DHCP or run with a static ip?"
   echo "NOTE: Swapping may change the connected IP, thus dropping SSH clients!"

   echo ""
   echo "D=DHCP    S=static"
   printf "[D]/S: "
   read reply
   reply=${reply:-D}

   if [[ $reply == "D" || $reply == "d"  ]]
   then
      DHCP
   elif [[ $reply == "S" || $reply == "s"  ]]
   then
      STATIC
   else
      echo "Unknown input. Rerun."
      exit 1
   fi
}

function STATIC
{
   echo ""

   cp ifcfg-eth0.template $ifcfg_file

   new_gateway=`cat $ifcfg_file | grep 'GATEWAY='`
   status=`echo $?`

   if (( $status == 0 ))
   then
      echo "New: $new_gateway"
   elif (( $status == 1 ))
   then
      echo "No gateway specified..."
      printf "Enter a new gateway or 'N' for none: "
      read new_gateway
      new_gateway=${new_gateway:-N}

      if [[ $new_gateway == "N" || $new_gateway == "n" ]]
      then
         echo "Ignoring gateway"
      else 
         echo "New gateway: $new_gateway"
         echo "GATEWAY=\"${new_gateway}\"" >> $ifcfg_file
      fi
   fi

   echo ""
   echo ""

   new_ip=`cat $ifcfg_file | grep 'IPADDR='`
   status=`echo $?`

   if (( $status == 0 ))
   then
      echo "New: $new_ip"
   elif (( $status == 1 ))
   then
      echo "No IP address specified..."
      printf "Enter a new IP: "
      read new_ip

      while [[ $new_ip == "" ]]
      do
         echo ""
         echo "No new IP specified."
         printf "Enter a new IP: "
         read new_ip
      done

      echo "New IP address: $new_ip"
      echo "IPADDR=\"${new_ip}\"" >> $ifcfg_file
   fi

   echo ""
   echo ""

   new_netmask=`cat $ifcfg_file | grep 'NETMASK='`
   status=`echo $?`

   if (( $status == 0 ))
   then
      echo "New: $new_netmask"
   elif (( $status == 1 ))
   then
      echo "No netmask specified..."
      printf "Enter a new netmask or 'D' for 255.255.255.0: "
      read new_netmask
      new_netmask=${new_netmask:-D}

      if [[ $new_netmask == "D" || $new_netmask == "d" ]]
      then
         new_netmask="255.255.255.0"
      fi

      echo "New netmask: $new_netmask"
      echo "NETMASK=\"${new_netmask}\"" >> $ifcfg_file
   fi
}

function USAGE
{
   echo "
############
SCRIPT USAGE
############

Script to swap between DHCP and static IP addresses based on the templates provided

OPTIONS:
   -d
      Change to DHCP...
   -p
      Run the prompt to choose between DHCP and static IPs
       - This is also called when used without flags
   -s
      Change to a static IP...
"

   exit 1
}

ifcfg_file="/etc/sysconfig/network-scripts/ifcfg-eth0"
cp $ifcfg_file ${ifcfg_file}.bkup

while getopts ":dhps" opt
do
   case $opt in
      d)
         DHCP
         flag="d"
         ;;
      h)
         echo ""
         USAGE
         ;;
      p)
         PROMPT
         flag="p"
         ;;
      s)
         STATIC
         flag="s"
         ;;
      ?)
         echo ""
         echo "Invalid option: -$OPTARG" >&2
         USAGE
         ;;
   esac
done

if [[ -z $flag ]]
then
   PROMPT
fi

echo ""
service network restart

echo ""
echo "Done!"
