# k8s-automation/Justfile

# Create a Python virtual environment and install dependencies
setup:
	python3 -m venv venv
	./venv/bin/pip install -r requirements.txt
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
