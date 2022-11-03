#! /bin/bash

ns=$1

usage () {
        echo "Usage: $1 <namespace> "
}

check_para()
{
        if [ -z $ns ]
        then
                echo "input value is null"
                usage
                exit 0
        fi
}

check_filePath()
{
	file_path=`find ./ -name kustomization.yaml`
}

change_nodeName()
{
for list in $file_path
do
	echo $list
	current_node=`grep "value: {kubernetes.io/hostname:" $list |awk -F: '{print $3}' |awk -F} '{print $1}'`
	echo "befor: "$current_node
	sed -i "s/$current_node/ mec-com-worker/" $list
	change_node=`grep "value: {kubernetes.io/hostname:" $list |awk -F: '{print $3}' |awk -F} '{print $1}'`
	echo "after: "$change_node

done
}

main()
{
check_para
cd /root/umec_boot/u5gc_deploy/$ns
check_filePath
change_nodeName
}

main
