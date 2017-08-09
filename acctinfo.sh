#!/bin/bash
#   this script print out your accounts VPC, subnet, security group, eip, ami, etc
#
TMPFILE1=tmp1.log
TMPFILE2=tmp2.log
TMPFILE=tmp.log
VPC=VPC.list
EIP=EIP.list
EC2=EC2.list
AMI=AMI.list
ELB=ELB.list

: > $VPC
: > $EIP
: > $EC2

export PROF=$1

echo "............... AMIs ................."
aws ec2 describe-images  --owners self --query 'Images[*].[ImageId,Tags[?Key==`Name`].Value[]]' --output text |  sed 's/None$/None\n/g' | sed '$!N;s/\n/ /g' > $AMI

sort $AMI | nl

#
echo "............... EFS FileSystem ............"
aws efs describe-file-systems --profile=$PROF \
     --query "FileSystems[*].[Name,FileSystemId]" \
     --output text | tr -s '\t' ' ' | nl > $TMPFILE
cat $TMPFILE

#
aws elb describe-load-balancers --query 'LoadBalancerDescriptions[].[LoadBalancerName,DNSName,VPCId]' --output text > $ELB

aws elbv2 describe-load-balancers --query 'LoadBalancers[].[LoadBalancerName,DNSName,VpcId]' --output text >> $ELB
echo "................... ELB & ALB .................."
cat $ELB | nl

#
vpc=( $(aws ec2  describe-vpcs --output=text | grep VPCS | awk '{ print $7}'))

for i in "${vpc[@]}"

do
  VPCID=`aws ec2 describe-vpcs   --filter "Name=vpc-id,Values=$i" --output=text | grep VPCS | awk '{ print $1, $2 , $7}'`
  VPCNAME=`aws ec2 describe-vpcs  --filter "Name=vpc-id,Values=$i" --output=text | grep TAGS | grep Name | awk '{ print $1, $3}'`
  echo "$VPCID $VPCNAME" >> $VPC
done

echo "............... VPCs ................."
sort -k5 $VPC | nl

#
aws ec2 describe-instances  --query 'Reservations[].Instances[].[PrivateIpAddress,PublicIpAddress,VpcId,InstanceId,Tags[?Key==`Name`].Value[]]' --output text --filters "Name=instance-state-name,Values=running" | sed 's/None$/None\n/g' | sed '$!N;s/\n/ /g' | nl > $EC2

echo "................. EC2 ................."
cat $EC2

echo "............ Elastic IPs .............."
aws ec2 describe-addresses  --output text \
    --query Addresses[*].[PublicIp,AllocationId,InstanceId] | nl > $EIP

cat $EIP

echo "............... Subnets ................"
sort -k5 $VPC | while read inrec
do
 VPCID=`echo $inrec | awk '{print $3}'`
 VPCNAME=`echo $inrec | awk '{print $5}'`
 aws ec2 describe-subnets  --filter "Name=vpc-id,Values=$VPCID" \
      --output=text | grep SUBNETS | awk '{ print $3 , $9, $10}' > $TMPFILE1

 aws ec2 describe-subnets  --filter "Name=vpc-id,Values=$VPCID" \
     --output=text | grep TAGS | grep Name |  awk '{ print $1, $3}' > $TMPFILE2

 paste -d " " $TMPFILE1 $TMPFILE2 | nl > $TMPFILE
 echo $VPCNAME
 cat $TMPFILE
done

echo "............ Security Groups ............"
sort -k5 $VPC | while read inrec
do
 VPCID=`echo $inrec | awk '{print $3}'`
 VPCNAME=`echo $inrec | awk '{print $5}'`
 aws ec2 describe-security-groups  \
    --query 'SecurityGroups[*].{GroupName:GroupName,GroupId:GroupId}' \
    --output=text --filters "Name=vpc-id,Values=$VPCID" | tr -s '\t' ' ' | nl > $TMPFILE
 echo $VPCNAME
 cat $TMPFILE
done

#
