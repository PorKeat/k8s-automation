# Kubernetes Cross-Cloud Automation (IaC)

This directory contains the fully automated Infrastructure as Code (IaC) pipeline for provisioning Google Cloud bare-metal instances, building an OS-level WireGuard mesh network, and deploying a scalable Kubernetes cluster via Kubespray.

## 📂 Directory Structure

```text
k8s-automation/
├── Justfile               # Simple shortcut commands
├── requirements.txt       # Python dependencies for Google Cloud
├── deploy.yml             # The Master Playbook
├── group_vars/
│   └── all.yml            # ⚙️ YOUR CONFIGURATION FILE
├── roles/
│   ├── provision_gcp/     # Creates VMs & Firewall Rules dynamically
│   ├── wireguard_mesh/    # Builds the OS-level 10.200.0.x VPN mesh
│   └── kubespray_trigger/ # Triggers the Kubespray installation
└── kubespray/             # The embedded Kubespray engine
```

## 🚀 How It Works

This project is **100% Declarative and Idempotent**. 

You do not need to manually create instances, track node IDs, or run complex networking commands. You simply declare what you want the cluster to look like in the `group_vars/all.yml` file, and the automation handles the rest.

---

## 🛠️ Getting Started

### 1. Install Dependencies (Virtual Environment)
Because Ansible requires specific Python libraries (`google-auth`, `requests`) to talk to Google Cloud, it is best practice to install them inside a Python Virtual Environment.

```bash
# Automatically create the venv and install requirements:
just setup

# Activate the virtual environment:
source venv/bin/activate
```

### 2. Authenticate with Google Cloud
Before you can provision instances, you must authenticate your terminal so Ansible has permission to build resources in your Google Cloud projects.

```bash
just auth
```

### 3. Define your Cluster Topology
Open `group_vars/all.yml` and define exactly how many Masters and Workers you want, and which GCP projects they belong to. 

```yaml
cluster_topology:
  - type: "master"
    count: 3
    project: "project-A-id"
    zone: "asia-southeast1-a"
    machine_type: "e2-standard-2"
  
  - type: "worker"
    count: 3
    project: "project-B-id"
    zone: "asia-southeast1-b"
    machine_type: "custom-4-8192"
```

### 4. Deploy the Cluster
Once your configuration is set, run the master playbook to trigger the entire pipeline!

```bash
just deploy
```
