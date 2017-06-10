#!/bin/bash
if [ $# -ne 2 ]; then
   echo "Usage: $0 profile owner"
   echo "i.e, $0 readonly 387946841317"
   exit 1
fi

PROFILE=$1
OWNER=$2

aws ec2 describe-images --profile $PROFILE --owners $OWNER --query "Images[].[Name,ImageId,Description]" --output text

#  end of file
