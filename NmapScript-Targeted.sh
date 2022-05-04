#!/bin/bash
# version 1.6 20220504: Edited this script to store all results in one file; other script does each subnet to seperate file. 
# Version 1.5 20200515: Added option for Cisco SmartInstall
# Version 1.4 20191120: Added option for nmap timing and useragent
# Version 1.3 20190312: Added EyeWitness execution after nmap scan
# Version 1.2 05/21/2018:
# - Added --min-hostgroup 256 --min-parallelism 64 to each scan
# Version 1.1 03/01/2018:
# - Added line to create nmap-exludefile.txt
# - Changed timeing to T4
# - Changed file output names
# Version 1.0 02/09/2018
# Regular Colors
# Regular Colors
Black='\033[0;30m'		# Black
Red='\033[0;31m'		# Red
Green='\033[0;32m'		# Green
Yellow='\033[0;33m'		# Yellow
Blue='\033[0;34m'		# Blue
Purple='\033[0;35m'		# Purple
Cyan='\033[0;36m'		# Cyan
White='\033[0;37m'		# White
NC='\033[0m'			# No Color


# Inititalization

scantypemenu () {
	echo -e ${Green} Start Nmap${NC}
	echo -e ""
	# Ask for agency name
	echo -e ${Green}"Target System Name: "${NC}
	read -e varOrgNameInput
	echo ""
	# Ask for subnet file input
	echo -e ${Green}"Subnet file(tab complete): "${NC}
	read -e varSubnetFileInput
    dos2unix $varSubnetFileInput
	echo ""
	echo -e ${Green}"Add any IP exclusions to: /root/working/nmap-excludefile.txt before continuing......"${NC}
	read -p ""
	if [ ! -f "/root/working/nmap-excludefile.txt" ]; then
		touch /root/working/nmap-excludefile.txt
	fi
	echo ""
	nmapspeedmenu () {
		echo -e ${Green}"Select Speed of scan: 1(fast=T4) 2(slow=T3)"${NC}
		read -e varTempNmapSpeed
		if [ "$varTempNmapSpeed" = "1" ]; then
			varNmapSpeed="-T4"
		elif [ "$varTempNmapSpeed" = "2" ]; then
			varNmapSpeed="-T3"
		else
			echo -e ${Red}"You have entered an invalid selection!"${NC}
			echo -e ${Red}"Please try again!"${NC}
			echo ""
			echo -e ${Red}"Press any key to continue..."${NC}
			read -n 1
			nmapspeedmenu
		fi
	}
	
	nmapspeedmenu
	echo ""
	mkdir -p /working/internal
	mkdir -p /working/external
	mkdir -p /working/internal/nmap
	mkdir -p /working/external/nmap
	
	varExclusions=/working/nmap-excludefile.txt
	varExternalOutputPath=/working/external/nmap/
	varExternalEyeWitnessPath=/working/external/eyewitness
	varInternalOutputPath=/working/internal/nmap/
	varInternalEyeWitnessPath=/working/internal/eyewitness
	varTempOutPutFile=/working/internal/nmap/"$varOrgNameInput"_tcp445.txt
	varTargetOutputFile=/working/internal/nmap/smbtgts.txt
  	varUserAgent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.120 Safari/537.36"

	echo ""
	echo -e ${Green}"Press 1 for an External Eyewitness Scan"${NC}
	echo -e ${Green}"Press 2 for an External Insecure Ports Scan"${NC}
	echo -e ${Green}"Press 3 for an External Top 2000 Ports Scan"${NC}
	echo -e ${Green}"Press 4 for an External All Ports Scan"${NC}
	echo -e ${Green}"Press 5 for an Internal Eyewitness Scan"${NC}
	echo -e ${Green}"Press 6 for an Internal Insecure Ports Scan"${NC}
	echo -e ${Green}"Press 7 for an Internal Top 2000 Ports Scan"${NC}
	echo -e ${Green}"Press 8 for an Internal All Ports Scan"${NC}
	echo -e ${Green}"Press 9 for an Internal SMB Targets Scan"${NC}
	echo -e ${Green}"Press 10 for an Internal Cisco SmartInstall Targets Scan"${NC}
	echo -e ${Green}"Press x to exit the script"${NC}
  read -n 2 -p "Input Selection:" scantypemenuinput
	echo ""
	if [ "$scantypemenuinput" = "1" ]; then
		echo -e ${Green}" External Eyewitness Scan Selected"${NC}
		nmap -vv -sT -A -sC -Pn $varNmapSpeed -p 80-89,443,8000-8999,9443,4443,10000,3389,3306,5900 --script http-methods --script-args http.useragent="$varUserAgent" --open --min-hostgroup 256 --min-parallelism 32 --stylesheet=https://svn.nmap.org/nmap/docs/nmap.xsl -oX $varExternalOutputPath"$varOrgNameInput"_ext_eyewitness.xml -iL $varSubnetFileInput --excludefile $varExclusions
		# Run Eyewitness
		cd /root/EyeWitness/Python
		./EyeWitness.py --user-agent "$varUserAgent" --web -x $varExternalOutputPath"$varOrgNameInput"_ext_eyewitness.xml --no-prompt --timeout 15 --results 100 -d $varExternalEyeWitnessPath
		elif [ "$scantypemenuinput" = "2" ]; then
			echo -e ${Green}"External Insecure Ports Scan Selected"${NC}
				nmap -vv -O -sV -sC -sT -A -Pn $varNmapSpeed -p 21,23,69,3389,5900 --open --min-hostgroup 256 --min-parallelism 32 --stylesheet=https://svn.nmap.org/nmap/docs/nmap.xsl -oA $varExternalOutputPath"$varOrgNameInput"_ext_insecureports -iL $varSubnetFileInput --excludefile $varExclusions
		scantypemenu
        elif [ "$scantypemenuinput" = "3" ]; then
			echo -e ${Green}"External Top 2000 Ports Scan Selected"${NC}
				nmap -vv -O -sV -sC -sT -A -Pn $varNmapSpeed --top-ports 2000 --script http-methods --script-args http.useragent="$varUserAgent" --open --min-hostgroup 256 --min-parallelism 32 --stylesheet=https://svn.nmap.org/nmap/docs/nmap.xsl -oA $varExternalOutputPath"$varOrgNameInput"_ext_top2000ports -iL $varSubnetFileInput --excludefile $varExclusions
		scantypemenu
		elif [ "$scantypemenuinput" = "4" ]; then
			echo -e ${Green}"External All Ports Scan Selected"${NC}
				nmap -vv -O -sV -sC -sT -A -Pn $varNmapSpeed -p 0-65535 --script http-methods --script-args http.useragent="$varUserAgent" --open --min-hostgroup 256 --min-parallelism 32 --stylesheet=https://svn.nmap.org/nmap/docs/nmap.xsl -oA $varExternalOutputPath"$varOrgNameInput"_ext_allports -iL $varSubnetFileInput --excludefile $varExclusions
		scantypemenu
		elif [ "$scantypemenuinput" = "5" ]; then
			echo -e ${Green}" Internal Eyewitness Scan Selected"${NC}
			nmap -vv -sT -A $varNmapSpeed -p 80-89,443,8000-8999,9443,4443,10000 --script http-methods --script-args http.useragent="$varUserAgent" --open --min-hostgroup 256 --min-parallelism 32 --stylesheet=https://svn.nmap.org/nmap/docs/nmap.xsl -oX $varInternalOutputPath"$varOrgNameInput"_int_eyewitness.xml -iL $varSubnetFileInput --excludefile $varExclusions
			# Run Eyewitness
			cd /root/EyeWitness/Python
			./EyeWitness.py --user-agent "$varUserAgent" --web -x $varInternalOutputPath"$varOrgNameInput"_int_eyewitness.xml --no-prompt --timeout 15 --results 100 -d $varInternalEyeWitnessPath
		scantypemenu
        elif [ "$scantypemenuinput" = "6" ]; then
			echo -e ${Green}"Internal Insecure Ports Scan Selected"${NC}
				nmap -vv -O -sV -sC -sT -A $varNmapSpeed -p 21,23 --open --min-hostgroup 256 --min-parallelism 32 --stylesheet=https://svn.nmap.org/nmap/docs/nmap.xsl -oA $varInternalOutputPath"$varOrgNameInput"_int_insecureports -iL $varSubnetFileInput --excludefile $varExclusions
		scantypemenu
        elif [ "$scantypemenuinput" = "7" ]; then
			echo -e ${Green}"Internal Top 2000 Ports Scan Selected"${NC}
				nmap -vv -O -sV -sC -sT -A $varNmapSpeed --top-ports 2000 --script http-methods --script-args http.useragent="$varUserAgent" --open --min-hostgroup 256 --min-parallelism 32 --stylesheet=https://svn.nmap.org/nmap/docs/nmap.xsl -oA $varInternalOutputPath"$varOrgNameInput"_int_top2000ports_$varSubnetFileInput -iL $varSubnetFileInput --excludefile $varExclusions
		scantypemenu
        elif [ "$scantypemenuinput" = "8" ]; then
			echo -e ${Green}"Internal All Ports Scan Selected"${NC}
				nmap -vv -O -sV -sC -sT -A $varNmapSpeed -p 0-65535 --script http-methods --script-args http.useragent="$varUserAgent" --open --min-hostgroup 256 --min-parallelism 32 --stylesheet=https://svn.nmap.org/nmap/docs/nmap.xsl -oA $varInternalOutputPath"$varOrgNameInput"_int_allports -iL $varSubnetFileInput --excludefile $varExclusions
		scantypemenu
        elif [ "$scantypemenuinput" = "9" ]; then
			echo -e ${Green}"Internal SMB Targets Scan Selected"${NC}
			nmap -vv -sT -A $varNmapSpeed --open -p 445 --min-hostgroup 256 --min-parallelism 32 --script smb-security-mode.nse -oN $varTempOutPutFile -iL $varSubnetFileInput --excludefile $varExclusions
			# logic came from https://github.com/actuated/check-smb-signing/blob/master/check-smb-signing.sh
			while read varThisLine; do
        		varCheckForScanReport=$(echo "$varThisLine" | grep "Nmap scan report for" --color=never)
        		if [ "$varCheckForScanReport" != "" ]; then
          			varLastHost=$(echo "$varThisLine" | awk '{print $NF}' | tr -d '()')
        		fi
        			varCheckForVulnState=$(echo "$varThisLine" | grep "message_signing" --color=never)
        		if [ "$varCheckForVulnState" != "" ]; then
          			varStatus=$(echo "$varThisLine" | awk '{print $2, $3}')
          			echo -e "$varLastHost" >> "$varTargetOutputFile"
        		fi
      		done < $varTempOutPutFile
      	scantypemenu
        elif [ "$scantypemenuinput" = "10" ]; then
			echo -e ${Green}"Internal Cisco SmartInstall Scan Selected"${NC}
			nmap -vv -sT -A $varNmapSpeed -p 4786 --open --min-hostgroup 256 --min-parallelism 32 -iL $varSubnetFileInput --excludefile $varExclusions | grep -B3 open | egrep -o "([0-9]{1,3}\.){3}[0-9]{1,3}" >> $varInternalOutputPath"$varOrgNameInput"_int_smartinstall.txt
		scantypemenu
        elif [ "$scantypemenuinput" = "x" ]; then
			exit
		else
			echo -e ${Red}"You have entered an invalid selection!"${NC}
			echo -e ${Red}"Please try again!"${NC}
			echo ""
			echo -e ${Red}"Press any key to continue..."${NC}
			read -n 1
			scantypemenu
		fi

}

# This builds the main menu and routs the user to the function selected

scantypemenu
