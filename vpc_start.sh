#!/bin/bash
set +x
ans_folder="/home/ubuntu/ansible"

if [ -z "$1" ]; then
  	echo "No parameter provided no terraform appy."
else
	terraform apply -auto-approve
	echo "get some 2 mins time for instances to start ssh. and install instances."
	sleep 120

fi

echo "copy ansible config files to server folder : ${ans_folder}."

python3 gen_ans_inventory1.py

ansible_ip=$(python3 get_ansible_server_ip.py)
#python3 get_ansible_server_ip.py | xargs -I {} scp -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa ans_conf/hosts ubuntu@{}:${ans_folder}/hosts
scp -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa ans_conf/hosts ubuntu@${ansible_ip}:${ans_folder}/hosts
scp -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa ans_conf/hosts.txt ubuntu@${ansible_ip}:${ans_folder}/hosts.txt
#python3 get_ansible_server_ip.py | xargs -I {} scp -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa ans_conf/ansible.cfg ubuntu@{}:${ans_folder}/ansible.cfg
scp -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa ans_conf/ansible.cfg ubuntu@${ansible_ip}:${ans_folder}/ansible.cfg
ssh ubuntu@${ansible_ip} "cd ansible && ansible --version && ansible -v -i hosts all -m ping"
