#! /bin/bash

alist="mongodb webui scp"
blist="udm pcf amf smf"
tnf=$1
mode=$2
ns="$3"

ue_count_all=5
supi_prefix=20893 
supi_length=010

#UE1:
#    members:
#    - imsi-208930000000001
#    topology:
#      - A: gNB
#        B: UPF




function check_list()
{
	if [ -z $tnf ]
	then
		echo "1st input value is null"
		usage
		exit 0
	fi
}


function check_mode()
{

	if [ -z $mode ]
	then
		echo "2nd input value is null"
		usage
		exit 0
	fi
}

function check_ns()
{
	if [ -z $ns ]
	then
		ns=`basename $PWD`
		echo "namespace not defined."
		echo "set default namespace: $ns"
	fi
	
	echo "**********************************"
	echo "$mode namespace is $ns"
	echo "**********************************"
	sleep 3
}


function usage () {
	echo "Usage: $1 <base|all|node> $2 <install|uninstall> $3 {namespace} "
	echo "                  base : mongodb jaeger webui scp"
	echo "                  core : nf pod(amf udm pcf smf)"
	echo "                  all : base & core"
	echo "                  node : mongodb|webui|jaeger|scp|amf|udm|pcf|smf"
}

function start_nf () {
	echo " install :  $1"
	kubectl apply -k $1  -n $ns --validate=false
}


function stop_nf () {
        echo " uninstall : $1"
        kubectl delete -k $1 -n $ns
}


function create_ns()
{
chk_ns=`kubectl get ns $ns 2>&1|grep "not found"|wc -l`
if [ $chk_ns -eq 1 ]
then
	echo "namespace not found, create namespace: $ns"
	kubectl create ns $ns
fi
}

function update_ns()
{
if [ -z $1 ]
then
	echo "function input null"
	exit 0
else
	chk_file_ns=`grep ^namespace $1/kustomization.yaml |wc -l`
	if [ $chk_file_ns -eq 1 ]
	then
		sed -i '/^namespace/d' $1/kustomization.yaml
		echo "" >> $1/kustomization.yaml
		echo "namespace: $ns" >> $1/kustomization.yaml
	else
		echo "" >> $1/kustomization.yaml
		echo "namespace: $ns" >> $1/kustomization.yaml
	fi
fi

}


function wait_nf () {
	for cnt in $(seq 20)
	do
		sn=`kubectl get pods -n $ns | grep $ns"-"$1 | awk '{print $3}'`
		if [ "$sn" == "Running" ] ; then
			break
		fi
		echo "wait $1 $mode ...."
		sleep 1
	done
}


function check_deploy()
{
max=5
i=0
echo "deploy status checking..."
while  [ $max -gt  $i ]
do
	 echo "-----> retry max($max), now($i)"
	 kubectl get po,svc -n $ns
	 i=$(($i+1))
	 sleep 2
done
}


function create_ue()
{
i=1
	while [ $ue_count_all -ge $i ]
	do
		ue_id=`printf "%${supi_length}d" "$i"`
		echo "    - imsi-$supi_prefix$ue_id"
		i=$(($i+1))
	done

}



function step1()
{
	for bf in $alist 
	do 
		update_ns $bf
		if [ $mode == "install" ]
		then
			start_nf $bf
		elif [ $mode == "uninstall" ]
		then
			stop_nf $bf
		else
			echo "unsupported option ($mode)"
			exit 0
		fi
    	sleep 1
	done
	check_deploy
}


function step2()
{

	for nf in $blist
	do
		update_ns $nf
		if [ $mode == "install" ]
		then
			wait_nf "scp"
			start_nf $nf
		elif [ $mode == "uninstall" ]
		then
			stop_nf $nf
		else
			echo "unsupported option ($mode)"
			exit 0
		fi
    	sleep 1
	done
	check_deploy
}



function main()
{
check_list
check_mode
check_ns
create_ns

if [ "$tnf" == "base" ] ; then
	step1
elif [ "$tnf" == "core" ] ; then
	step2
elif [ "$tnf" == "all" ] ; then
	step1
	sleep 2
	step2
elif [ "$tnf" == "ue" ] ; then
	create_ue
else
	if [ $mode == "install" ]
	then
		echo "---------------------------"
		echo "start nf : $tnf "
		echo "---------------------------"
		sleep 1
		start_nf $tnf
	elif [ $mode == "uninstall" ]
	then
		echo "---------------------------"
		echo "stop nf : $tnf "
		sleep 1
		stop_nf $tnf
		echo "---------------------------"
	else
		echo "unsupported option ($mode)"
		exit 0
	fi
fi 

}


main
