#!/bin/bash

if [ $# -ne 1 ] ; then
   echo "Usage: $0 profile"
   echo "List all Elastic IPs"
   exit 1
fi
PROF=$1
aws ec2 describe-addresses --profile $PROF --output text --query "Addresses[*].[AssociationId,PublicIp,InstanceId]"
