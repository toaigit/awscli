#!/bin/sh
#  list all running instance with PrivateIP and ServerName Tag
if [ $# -ne 1 ] ; then
#   echo "Usage: $0 profile vpcid"
    echo "Usage: $0 profile"
   exit 1
fi
PROF=$1

aws ec2 describe-instances --profile $PROF --query 'Reservations[].Instances[].[PrivateIpAddress,PublicIpAddress,VpcId,InstanceId,Tags[?Key==`Name`].Value[]]' --output text --filters "Name=instance-state-name,Values=running" | sed 's/None$/None\n/g' | sed '$!N;s/\n/ /g'

