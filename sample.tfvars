[ ! -z $1 ] || { echo "No Arguement" ; echo usage: ./$0 accesss_key secret_key ; kill -9 $$ > /dev/null 2>&1; }
echo """
regions=\"[me-south-1]\"
tags=\"always-on\"
aws_access=\"$1\"
aws_secret=\"$2\"
""" | grep -v '^$' | base64 > ${3}-enc.tfvars 
