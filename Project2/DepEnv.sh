#! /bin/bash

#------------PRESCRIPT_STATS------------
#Color Variables for readability
NC='\e[39m'	#No color
R='\e[91m'	#Red
G='\e[92m'	#Green
C='\e[96m'	#Cyan
M='\e[95m'	#Magenta
Y='\e[93m'	#Yellow

#Other variables
NODE_STOP_TEST=0	#Number of nodes which are active, breaks the loop at 0 after checking
CERT_TEST=0		#Number of certificate requests, breaks the loop when it reaches 6
FOREMAN_TEST=0		#Number of nodes which are found in foreman, breaks the loip when it reaches 6

#Functions
#---Repeat Print---
print_rep() {
	str=$1
	num=$2
	v=$(printf "%-${num}s" "$str")
	echo -e "${Y}${v// /$str}"
}

#Set source so nova commands are usable
source .openstack

#------------SCRIPT_START------------
#Stop all nodes from project p2 if running
echo -e "${Y}Stopping all running nodes...${M}\n"
mln stop -p p2
sleep 1
echo -e "\n${Y}Waiting for all nodes to stop.\n"
#While loop that breaks when there is no more active servers
while true;
do
	#Node equates to the nova list host status column
        for NODE in $(nova list | grep p2 | awk '{printf "%s\n",$6}')
        do
                if [ "$NODE" == "ACTIVE" ]
                then
                        let NODE_STOP_TEST=NODE_STOP_TEST+1
                        print_rep "." $NODE_STOP_TEST
                fi
		sleep 0.1
        done

        if [ $NODE_STOP_TEST -eq 0 ]
        then
                break
        fi

        NODE_STOP_TEST=0
done
echo -e "\n${G}All running nodes have stopped!\n"
sleep 1

#Remove old mln project
echo -e "${Y}Removing old mln project...${M}"
mln remove -p p2 -f
echo -e "\n${G}Old project, p2, is removed!\n"
sleep 1

#Remove all old certificates
echo -e "${Y}Removing old puppet certificates...\n"
#For loop that findes the names of all signed certificates and then removes them
for CERT in $(ls /var/lib/puppet/ssl/ca/signed | sed 's/.pem//' )
do
	#An if test to make sure not to remove the master server from the certificates
        if [ "$CERT" != "master.openstacklocal" ]
        then
                echo -e "${Y}Removing ${C}$CERT ${Y}from signed certificates."
                puppet cert clean $CERT
        fi
done
echo -e "\n${G}All certificates are removed!\n"
sleep 1

#Build the mln file
echo -e "${Y}Building project from mln file \"Project2.mln\"...${M}\n"
mln build -f Project2.mln
echo -e "\n${G}MLN project built!\n"
sleep 1

#Start the mln project
echo -e "${Y}Starting mln project \"p2\"...${M}\n"
mln start -p p2
echo -e "\n${G}MLN project started!\n"
sleep 1

#Check for certificate requests then signs them
echo -e "${Y}Looking for puppet certificates to sign...\n"
#While loop that will continue to run the for loop until all certs are found
while true;
do
	for CERT in $(ls /var/lib/puppet/ssl/ca/requests | sed 's/.pem//' )
	do
 	     	echo -e "${y}Found certificate request from ${C}$CERT.${Y}"
		puppet cert sign $CERT
		let CERT_TEST=CERT_TEST+1
		echo -e "${Y}Signed ($CERT_TEST/6)."
	done

	#An if test to check if all certs are signed, then breaks if true
	if [ $CERT_TEST -eq 6 ]
	then
		break
	fi
done
echo -e "\n${G}All certificates have been signed!\n"

#Make sure all new nodes are subjects of Backup from the backup server
#First we add the consant servers
echo -e "${Y}Creating configuration file for backup...\n"
echo "10.0.8.71:/etc,/root,/home" >> bkup_plan.conf
echo "10.0.16.15:/etc,/root,/home" >> bkup_plan.conf
echo "10.0.16.16:/etc,/root,/home" >> bkup_plan.conf
#Collect IP-addresses of all new nodes in the mln project p2 and adds them to the bkup_plan.conf file
nova list | while read line;
do
        if [[ $line == *"p2"* ]]
        then
		echo -e "${Y} Node:"
		echo -e $line | awk '{printf $4}' | sed 's/\.p2//'
		echo -e "\n${Y} added to the backup file!\n"
                echo $line | awk '{printf $12}' | sed 's/netsys_net=//' >> bkup_plan.conf
                echo ":/etc,/home" >> bkup_plan.conf
        fi
done
echo -e "\n${Y}All nodes added to backup file!\nPreceding to transfer file to backup server...\n"
#Send the new backup configuration file
scp bkup_plan.conf ubuntu@10.0.17.70:/home/ubuntu
#After file is sent we can delete it locally
rm bkup_plan.conf
echo -e "\n${G}Backup Configuration completed!\n"

#Check for nodes in foreman
echo -e "${Y}Waiting for hosts to show up in foreman...\nThis may take a while, please have patience.\n"
while true;
do
	FOREMAN_TEST=$(hammer -u admin -p GM_login host list | awk '{ printf "%s\n",$3 }' | sed 's/NAME//' | sed 's/master.openstacklocal//' | sed '/^\s*$/d'| wc -l)
	echo -e "${Y}Found ($FOREMAN_TEST/6)."

	if [ $FOREMAN_TEST -eq 6 ]
	then
		break
	fi
	sleep 5
done
echo -e "${G}\nAll hosts found!\nProceeding to assign hostgroups if they are missing.\n"
#For loop that finds the name of all the nodes discovered in foreman
for NODE in $(hammer -u admin -p GM_login host list | awk '{ printf "%s\n",$3 }' | sed 's/NAME//' | sed 's/master.openstacklocal//' | sed '/^\s*$/d')
do
        #If the grep return no value, it means the node is not currently in a host group
        if [ -z "$(hammer -u admin -p GM_login host info --name $NODE | grep 'Host Group')" ]
        then
                echo -e "${R}Missing Host Group for node $NODE."
                echo -e "${Y}Adding to Host Group!"

                #Case statement that uses the node prefix to put it in the correct host group
                case "$NODE" in

                        comp*)
                                hammer -u admin -p GM_login host update --name $NODE --hostgroup Compile
                                echo -e "${G}$NODE put in Compile."
                                echo
                                ;;
                        dev*)
                                hammer -u admin -p GM_login host update --name $NODE --hostgroup Development
                                echo -e "${G}$NODE put in Development."
                                echo
                                ;;
                        sto*)
                                hammer -u admin -p GM_login host update --name $NODE --hostgroup Storage
                                echo -e "${G}$NODE put in Storage."
                                echo
                esac
        fi
done
echo -e "\n${G}All hosts have been assigned to host groups!\n"
sleep 1

echo -e "DEPLOYMENT COMPLETED${NC}"
#------------SCRIPT_STOP------------

#------------REFERENCES------------
#Color codes and how to use them: https://misc.flogisoft.com/bash/tip_colors_and_formatting
#Repeat print function: https://stackoverflow.com/questions/5799303/print-a-character-repeatedly-in-bash
#Sed usage: https://www.digitalocean.com/community/tutorials/the-basics-of-using-the-sed-stream-editor-to-manipulate-text-in-linux
