#!/bin/bash
set +x
ans_folder="/home/ubuntu/ansible"

echo "copy ansible config files from server folder : ${ans_folder}."

ansible_ip=$(python3 get_ansible_server_ip.py)

#scp -r -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa ubuntu@${ansible_ip}:${ans_folder}/ans_conf ${ans_folder}/ans_conf

scp -r -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa ubuntu@${ansible_ip}:${ans_folder}/playbooks .
