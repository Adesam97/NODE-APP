#!/bin/bash
echo "------------------------------------------------------------"
echo "exporting ip..."
echo "------------------------------------------------------------"
# Set the environmental variable value
export TF_INSTANCE_IP=$(terraform output -raw public_ip)

echo "------------------------------------------------------------"
echo "checking file and variable..."
echo "------------------------------------------------------------"

# Define the file path and the string to replace
file_path="../ansible/inventory.yml"
string_to_replace="instance-ip"

# Check if the file exists
if [ ! -f "$file_path" ]; then
  echo "File not found: $file_path"
  exit 1
fi

# Check if the environment variable is set
if [ -z "$TF_INSTANCE_IP" ]; then
  echo "Environment variable ENV_VARIABLE is not set."
  exit 1
fi

echo "all checks done"


# Replace the string in the file
sed -i "s/${string_to_replace}/${TF_INSTANCE_IP}/g" "$file_path"

echo "String replaced successfully."

echo "------------------------------------------------------------"
echo "executing ansible playbook..."
echo "------------------------------------------------------------"

# Change directory to ansible and execute playbook
cd ../ansible/
ansible-playbook -i ./inventory.yml ec2_playbook.yaml

#Replacing the sting in inventory
sed -i "s/${TF_INSTANCE_IP}/${string_to_replace}/g" "$file_path"

echo "--------------------------------------------------"
echo "All done "
echo "------------------------------------------------------------"