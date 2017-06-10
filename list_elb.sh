#!/bin/bash
if [ $# -ne 1 ] ; then
   echo "Usage:  $0 profile"
   exit 1
fi
PROF=$1
INSTANCES=/tmp/elb-instances_$$.file

aws elb describe-load-balancers --profile $PROF --query "LoadBalancerDescriptions[].Instances[*]" --output text > $INSTANCES

cat $INSTANCES | while read instanceid
do
   status=$(aws ec2 describe-instances --instance-id $instanceid --profile $PROF --query Reservations[].Instances[*].State.Name --output text)
   echo "instance-id $instanceid ... $status"
done

/bin/rm $INSTANCES
