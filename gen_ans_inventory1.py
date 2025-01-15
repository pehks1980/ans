import json
import subprocess

# Define your mappings between environment and hostnames
host_mappings = {
    "stage": {"ip_key": 0},  # Use the first IP for "stage"
    "prod": {"ip_key": 1}   # Use the second IP for "prod"
}

# SSH key path
ssh_key_path = "/home/ubuntu/.ssh/ansible_key"
conf_path = "ans_conf"

# Function to get Terraform output
def get_terraform_ips():
    try:
        terraform_output = subprocess.check_output(["terraform", "output", "-json"], text=True)
        client_ips = json.loads(terraform_output)["client_ips"]["value"]
        return client_ips
    except Exception as e:
        print(f"Error fetching Terraform output: {e}")
        return []

# Function to generate the hosts file
def generate_hosts_file(client_ips, output_file=f"{conf_path}/hosts"):
    try:
        with open(output_file, "w") as f:
            for group, data in host_mappings.items():
                ip = client_ips[data["ip_key"]]
                f.write(f"[{group}]\n")
                f.write(f"{ip}\n\n")
            # add ending
            f.write("""
[ALL:children]
stage
prod

[ALL:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/home/ubuntu/.ssh/ansible_key""")
            print(f"Hosts file generated: {output_file}")
    except Exception as e:
        print(f"Error generating hosts file: {e}")


if __name__ == "__main__":
    # Get IPs from Terraform
    ips = get_terraform_ips()
    if len(ips) < len(host_mappings):
        print("Not enough IPs available to map all hosts. Check Terraform output.")
    else:
        # Generate the Ansible hosts file
        generate_hosts_file(ips)

