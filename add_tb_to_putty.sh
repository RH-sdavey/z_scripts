#!/bin/bash

#author: Sean.davey@tieto.com
# made this when I was bored one day, 
# it should work, but I basically never used it.
# if you wish to use it, but it doesnt work, please contact sean 
# otherwise its basically useless :)

#===================INFO
# takes any new created vhts tb name
# finds the identity file
# and the port number
# adds this to a newly created putty session

#====================REQUIREMENTS
# putty installed to ~/Downloads/putty-0.71 ( or change the line below to the correct place and version ) 
puttyPath=~/Downloads/putty-0.71

#====================VARIABLES
testbed="/proj/athena/tools/testbed/testbed"
myDir="/tmp/testbed_$(whoami)"
VHTSIDFILE=$(ls "${myDir}"/identity_*)


#convert old pem style key to new style
if [ ! -s "${myDir}"/id_file_new ] ; then 
	"${puttyPath}"/puttygen "${VHTSIDFILE}" -o "${myDir}"/id_file_new
fi

#for each vhts instance, add details to putty
pushd $myDir
for vhts in $("${testbed}" list | grep -e "^vhts.block" | awk '{print $1}') ; do

	#dont do anything if a putty session already exists with this name
	if [ -s ~/.putty/sessions/$vhts ] ; then 
		continue
	fi

	VHTSCONFIG=./"$vhts"_ssh_config
	GWPORT=$(sed -n '1,11s|<port>\(.*\)</port>|\1|p' ./"$vhts"_taf_config.xml | sed 's/^[[:space:]]*//g')
	GWUSER="athena"
	
	cp ~/.putty/sessions/backup ~/.putty/sessions/"$vhts"
	sed -i s/HostName=/HostName=localhost/ ~/.putty/sessions/"$vhts"
	sed -i s/PortNumber=22/PortNumber="$GWPORT"/ ~/.putty/sessions/"$vhts"
	sed -i s/UserName=/UserName="$GWUSER"/ ~/.putty/sessions/"$vhts"
	sed -i "s&PublicKeyFile=&PublicKeyFile=${myDir}/id_file_new&" ~/.putty/sessions/"$vhts"
done
popd
