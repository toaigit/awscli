#!/bin/bash
if [ $# -ne 1 ] ; then
   echo "Usage: $0 profile"
   exit 1
fi

export PROF=$1

vpc=( $(aws ec2 --profile $PROF describe-vpcs --output=text | grep VPCS | awk '{ print $7}'))

for i in "${vpc[@]}"

do
  VPCID=`aws ec2 describe-vpcs --profile $PROF  --filter "Name=vpc-id,Values=$i" --output=text | grep VPCS | awk '{ print $1, $2 , $7}'`
  VPCNAME=`aws ec2 describe-vpcs --profile $PROF --filter "Name=vpc-id,Values=$i" --output=text | grep TAGS | grep Name | awk '{ print $1, $3}'`
  echo "$VPCID $VPCNAME"
done

#  end of script
