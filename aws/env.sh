#!/bin/bash
# set AWS environment for a specified $ENV_NAME and $AWS_REGION
# usage: source env.sh env region profile
# specify profile if aws user assume a role of a different account, the assumed role should be defined in ~/.aws/config
# you may also set AWS_PROFILE=your_profile, and do not pass any variables to this script to use default config
# default value: ENV_NAME="fab", AWS_REGION="us-west-2"

# number of EC2 instances to create for the cluster
export EKS_NODE_COUNT=3
# type of node instances to create
export EKS_NODE_TYPE=t2.medium
#export EKS_NODE_TYPE=m5.xlarge
export AWS_CLI_HOME=${HOME}/.aws

##### usually you do not need to modify parameters below this line

# return the full path of this script
function getScriptDir {
  local src="${BASH_SOURCE[0]}"
  while [ -h "$src" ]; do
    local dir ="$( cd -P "$( dirname "$src" )" && pwd )"
    src="$( readlink "$src" )"
    [[ $src != /* ]] && src="$dir/$src"
  done
  cd -P "$( dirname "$src" )" 
  pwd
}

if [[ ! -z "${1}" ]]; then
  export ENV_NAME=${1}
fi
if [[ -z "${ENV_NAME}" ]]; then
  export ENV_NAME="fab"
fi
if [[ ! -z "${3}" ]]; then
  export AWS_PROFILE=${3}
  echo "set aws profile ${AWS_PROFILE}"
fi
if [[ ! -z "${2}" ]]; then
  export AWS_REGION=${2}
  echo "set aws region ${AWS_REGION}"
  aws configure set region ${AWS_REGION}
fi
if [[ -z "${AWS_REGION}" ]]; then
  export AWS_REGION=$(aws configure get region)
fi
if [[ -z "${AWS_REGION}" ]]; then
  export AWS_REGION="us-west-2"
  echo "set aws region ${AWS_REGION}"
  aws configure set region ${AWS_REGION}
fi

export AWS_ZONES=${AWS_REGION}a,${AWS_REGION}b,${AWS_REGION}c
export EKS_STACK=${ENV_NAME}-eks-stack
export EFS_STACK=${ENV_NAME}-efs-client
export S3_BUCKET=${ENV_NAME}-s3-share
export EFS_VOLUME=vol-${ENV_NAME}
export BASTION=ec2-54-203-4-240.us-west-2.compute.amazonaws.com

export SCRIPT_HOME=$(getScriptDir)
export KUBECONFIG=${SCRIPT_HOME}/config/config-${ENV_NAME}.yaml
export EFS_CONFIG=${SCRIPT_HOME}/config/${EFS_STACK}.yaml
export KEYNAME=${ENV_NAME}-keypair
export SSH_PUBKEY=${SCRIPT_HOME}/config/${KEYNAME}.pub
export SSH_PRIVKEY=${SCRIPT_HOME}/config/${KEYNAME}.pem

if [ ! -f ${SSH_PRIVKEY} ]; then
  mkdir -p ${SCRIPT_HOME}/config
fi
