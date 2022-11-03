#! /bin/bash

alist="mongodb webui scp"
blist="amf udm pcf smf"
tnf=$1

function usage () {
	echo "Usage: $1 <base|all|node>"
	echo "       base : mongodb webui scp"
	echo "       all : nf pod(amf udm pcf smf)"
	echo "       node : mongodb|webui|scp|amf|udm|pcf|smf"
}

function stop_nf () {
	echo "
stop  $1"
	kubectl delete -k $1
}

if [ "$tnf" = "" ] ; then
	usage $0
	exit
fi

if [ "$tnf" == "base" ] ; then
	for bf in $alist 
	do 
		stop_nf $bf
	done
	./status_kustom.sh
elif [ "$tnf" == "all" ] ; then
	for nf in $blist
	do
		stop_nf $nf
	done
	./status_kustom.sh
else
	stop_nf $tnf
fi 
