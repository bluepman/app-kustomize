#! /bin/bash

alist="mongodb webui scp"
blist="amf udm pcf smf"
tnf=$1
ns=`basename $PWD`
ens=`kubectl get namespace | grep $ns`

function usage () {
	echo "Usage: $1 <base|all|node>"
	echo "                  base : mongodb webui scp"
	echo "                  all : nf pod(amf udm pcf smf)"
	echo "                  node : mongodb|webui|scp|amf|udm|pcf|smf"
}

function start_nf () {
	echo "
start  $1"
	kubectl apply -k $1 --validate=false
}

function wait_nf () {
	for cnt in $(seq 20)
	do
		sn=`kubectl get pods -n $ns | grep "u5gc-"$1 | awk '{print $3}'`
		if [ "$sn" == "Running" ] ; then
			break
		fi
		echo "wait $1 starting...."
		sleep 1
	done
}

if [ "$ens" == "" ] ; then
	kubectl apply -f 00_namespace.yaml
fi

if [ "$tnf" == "" ] ; then
	usage $0
	exit
fi

# kubectl apply -k em

if [ "$tnf" == "base" ] ; then
	for bf in $alist 
	do 
		start_nf $bf
    	sleep 1
	done
	./status_kustom.sh
elif [ "$tnf" == "all" ] ; then
	wait_nf "scp"

	for nf in $blist
	do
		start_nf $nf
    	sleep 1
	done
	./status_kustom.sh
else
	start_nf $tnf
fi 
