#!/bin/bash
[ ! -n $1 ] || { echo -e "Please pass the account id as arguement\n Usage: \n ./$0 <Account ID> "; kill -9 $$ ; }
terraform plan --var-file=<( cat ${1}-enc.tfvars | base64 -d ) -out ${1}.plan
terraform apply  -auto-approve  ${1}.plan
