# k8s-automation/Justfile

# Create a Python virtual environment and install dependencies
setup:
	python3 -m venv venv
	./venv/bin/pip install -r requirements.txt
	./venv/bin/ansible-galaxy collection install kubernetes.core
	@echo "\n Setup complete! To activate the environment, run:"
	@echo "source venv/bin/activate\n"

# Authenticate with Google Cloud using Application Default Credentials
auth:
	gcloud auth application-default login

# Run the master deployment playbook (Provisions GCP VMs)
deploy:
	./venv/bin/ansible-playbook deploy.yml

# Check syntax of the Ansible playbooks without running them
check:
	ansible-playbook --syntax-check deploy.yml

# Scale up the cluster after adding nodes to topology
scale:
	./venv/bin/ansible-playbook -i inventory/hosts.ini kubespray/scale.yml -b -e @group_vars/all.yml

# Remove a specific node (Usage: just remove-node node1)
remove-node NODE:
	./venv/bin/ansible-playbook -i inventory/hosts.ini kubespray/remove-node.yml -b -e "node={{NODE}} reset_nodes=true allow_ungraceful_removal=true" -e @group_vars/all.yml

# Gracefully reset the cluster and destroy GCP instances to stop billing
destroy:
	./venv/bin/ansible-playbook destroy.yml
