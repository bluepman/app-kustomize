#! /bin/bash

watch -c 'kubectl get pods -n $(basename $PWD) -o wide && echo "" && kubectl get svc -n $(basename $PWD) -o wide'
