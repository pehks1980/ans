import subprocess
import json

# Function to get Terraform output for a specific variable
def get_terraform_output(output_name):
    try:
        output = subprocess.check_output(["terraform", "output", "-json"], text=True)
        output_data = json.loads(output)
        return output_data.get(output_name, {}).get("value", None)
    except Exception as e:
        print(f"Error fetching Terraform output for {output_name}: {e}")
        return None

if __name__ == "__main__":
    # Fetch the Ansible server's public IP
    ansible_ip = get_terraform_output("ansible_server_public_ip")
    if ansible_ip:
        print(ansible_ip)  # Output only the IP

