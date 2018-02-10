#! /bin/bash

#Variables
RED='\033[0;31m' 	#Red Color
GREEN='\033[0;32m'	#Green Color
NC='\033[0m'    	#No Color
i=1
sp="/-\|"

#Start by stopping and removing already running machines

#Stop all machines running in Project1
echo -e "${GREEN}SHUTTING DOWN ALL OLD NODES${NC}"
echo -e "${GREEN}-----------------------------------${NC}"
mln stop -p Project1
echo
echo -e "${GREEN}FINISHED TASK${NC}"
sleep 10

#Remove all machines running in Project1, yes will cause the prompt to be automatically assigned as yes
echo
echo -e "${GREEN}REMOVING ALL OLD NODES${NC}"
echo -e "${GREEN}-----------------------------------${NC}"
yes | mln remove -p Project1
echo
echo -e "${GREEN}FINISHED TASK${NC}"
sleep 1

#Remove old certificates
echo
echo -e "${GREEN}REMOVING ALL OLD CERTIFICATES${NC}"
echo -e "${GREEN}-----------------------------------${NC}"
puppet cert clean db1
puppet cert clean db2
puppet cert clean web1
puppet cert clean web2
puppet cert clean webnode
puppet cert clean mem
puppet cert clean lb
echo
echo -e "${GREEN}FINISHED TASK${NC}"
sleep 1

#Build and start the mln file/project
echo
echo -e "${GREEN}BUILDING PROJECT FROM FILE${NC}"
echo -e "${GREEN}-----------------------------------${NC}"
mln build -f Project1.mln
echo
echo -e "${GREEN}FINISHED TASK${NC}"
sleep 1

echo
echo -e "${GREEN}STARTIING PROJECT${NC}"
echo -e "${GREEN}-----------------------------------${NC}"
mln start -p Project1
echo
echo -e "${GREEN}FINISHED TASK${NC}"
sleep 3

#Check for pending certificates and sign them
echo
echo -e "${GREEN}CERTIFICATE LOOKUP${NC}"
x=$(puppet cert list | wc -l)
while true;
do
	x=$(puppet cert list | wc -l)
	printf "${sp:i++%${#sp}:1}"

	case "$x" in

        	0) echo -ne '[-------------------------] 0%\r'
           	;;
        	1) echo -ne '[####---------------------] 14%\r'
           	;;
        	2) echo -ne '[#######------------------] 29%\r'
           	;;
        	3) echo -ne '[###########--------------] 43%\r'
           	;;
        	4) echo -ne '[##############-----------] 57%\r'
           	;;
        	5) echo -ne '[##################-------] 71%\r'
           	;;
        	6) echo -ne '[######################---] 86%\r'
           	;;
        	7) echo -ne '[#########################] 100%\r'
		echo 
           	echo -e "${GREEN}FINISHED${NC}"
           	echo -e "${GREEN}PROCEEDING TO SIGNING${NC}"
           	echo
           	sleep 3
           	break
           	;;
        esac
done
echo -e "${GREEN}-----------------------------------${NC}"
puppet cert sign --all
echo -e "${GREEN}FINISHED TASK${NC}"
echo
echo -e "${GREEN}DEPLOYMENT FINISHED${NC}"

