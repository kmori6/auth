#!/usr/bin/env bash

out_dir=".ssh"
ssh_key_name="jwt_rsa"
scripts_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="${scripts_dir}/../"

cd ${project_root}
mkdir -p ${out_dir}

# pem format for jwt
ssh-keygen -t rsa -b 4096 -m pem -f ${out_dir}/${ssh_key_name} -N ""
ssh-keygen -e -m pem -f ${out_dir}/${ssh_key_name}.pub > ${out_dir}/${ssh_key_name}_pub.pem

JWT_PRIVATE_KEY=$(awk '{printf "%s\\n", $0}' ${out_dir}/${ssh_key_name})
echo "JWT_PRIVATE_KEY=\"${JWT_PRIVATE_KEY}\""
