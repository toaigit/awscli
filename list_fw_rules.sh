#!/bin/bash
#
if [ $# -ne 1 ] ; then
   echo "Usage: $0 profile"
   exit 1
fi
PROF=$1
. deploy.functions
select_vpcs
select_sgroup

aws ec2 describe-security-groups --group-id $SG  | egrep "GroupName|IpRanges|CidrIp|Egres|ToPort"
