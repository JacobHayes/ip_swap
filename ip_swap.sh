function CHECK_CONNECTION
{
   ping -c 1 -t 60  www.google.com &> /dev/null

   echo ""

   if (( `echo $?` == 0 ))
   then
      echo "Connected to the internet..."
   else
      echo "Not connected to the internet..."
   fi
}

function DHCP
{
   cp ifcfg-eth0_dhcp /etc/sysconfig/network-scripts/ifcfg-eth0

   echo "New IP is unknown. Check you DHCP server or try ip_tester.sh to check for hosts."
}

function PROMPT
{
   echo "Would you like to connect to DHCP or run with a static ip?"
   echo "NOTE: Swapping may change the connected IP, thus dropping SSH clients!"

   CHECK_CONNECTION

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
   cp ifcfg-eth0_static /etc/sysconfig/network-scripts/ifcfg-eth0

   new_ip=`cat ifcfg-eth0_static | grep 'IPADDR='`
   echo "New:  $new_ip"
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

while getopts ":dps" opt
do
   case $opt in
      d)
         DHCP
         flag="d"
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

service network restart

echo ""
echo "Done!"
