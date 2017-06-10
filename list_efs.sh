#!/bin/bash
if [ $# -ne 1 ] ; then
   echo "Usage: $0 profile"
   exit 1
fi

PROF=$1
aws efs describe-file-systems --profile=$PROF --query "FileSystems[*].[Name,FileSystemId]" --output text
