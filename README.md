# Kubernetes Cross-Cloud Automation (IaC)

This directory contains a fully automated Infrastructure as Code (IaC) pipeline for provisioning Google Cloud bare-metal instances, building an OS-level WireGuard mesh network, and deploying a highly scalable, production-ready Kubernetes cluster via Kubespray.

## 📂 Directory Structure

```text
k8s-automation/
├── Justfile               # Simple shortcut commands
├── requirements.txt       # Python dependencies for Google Cloud
├── deploy.yml             # The Master Deployment Playbook
├── destroy.yml            # The Master Teardown Playbook
├── group_vars/all/        # 🎛️ YOUR CLUSTER CONTROL PANEL
│   ├── 01-topology.yml    # (Servers, IPs, and WireGuard)
│   ├── 02-resources.yml   # (CPU and RAM reservations)
│   ├── 03-network.yml     # (Network plugin choices)
│   ├── 04-addons.yml      # (Helm chart true/false switches)
│   └── 05-advanced.yml    # (Specialized settings like GPUs & Proxies)
├── roles/
│   ├── provision_gcp/     # Creates VMs & Firewall Rules dynamically
│   ├── wireguard_mesh/    # Builds the OS-level 10.200.0.x VPN mesh
│   ├── kubespray_trigger/ # Triggers the Kubespray installation
│   ├── kubespray_reset/   # Safely resets Kubernetes nodes
│   └── teardown_gcp/      # Deletes VMs & Firewall Rules dynamically
└── kubespray/             # The embedded Kubespray engine
```

## 🚀 How It Works

This project is **100% Declarative and Idempotent**. 

You do not need to manually create instances, track node IDs, or run complex networking commands. You simply declare what you want the cluster to look like in the 5 tiny configuration files in `group_vars/all/`, and the automation handles the rest.

---

## 🛠️ Getting Started

### 1. Install Dependencies (Virtual Environment)
Because Ansible requires specific Python libraries to talk to Google Cloud, it is best practice to install them inside a Python Virtual Environment.

```bash
# Automatically create the venv and install requirements:
just setup

# Activate the virtual environment:
source venv/bin/activate
```

### 2. Authenticate with Google Cloud
Before you can provision instances, you must authenticate your terminal so Ansible has permission to build resources.

```bash
just auth
```

### 3. Define your Cluster Topology & SSH Keys
Open `group_vars/all/01-topology.yml` and define your desired setup. This pipeline supports a unified approach, allowing you to mix dynamically provisioned instances (GCP) with your own existing instances (Bring Your Own Instances).

**Scenario A (Start from Scratch):** Use `count`. Ansible will build the VMs in GCP.
**Scenario B (Bring Your Own Everything):** Use `ips`. Ansible skips GCP provisioning and uses your existing servers.
**Scenario C (Hybrid):** Mix both `count` and `ips`! Ansible will create the GCP instances and then merge them seamlessly with your existing nodes.

*Note: You must also set your `ansible_ssh_private_key_file` path here so Ansible knows how to connect to your machines!*

### 4. Enable Add-ons & Helm Tools
Open `04-addons.yml` to automatically install core Kubernetes tools like Nginx Ingress or Cert-Manager. 

**Post-Install Apps:** At the bottom of `04-addons.yml`, you can also toggle massive enterprise-grade tools like **Longhorn** (Distributed Storage) and **Prometheus/Grafana**. The pipeline will deploy these automatically via Helm after the cluster boots!

### 5. Deploy the Cluster
Once your configuration is set, run the master playbook to trigger the entire pipeline!

```bash
just deploy
```
*(Safety First: A Pre-Flight Validation system will instantly run to ensure you haven't forgotten to set your GCP Project ID or SSH keys, preventing cryptic API crashes!)*

---

## ⚙️ Day-2 Operations

Once the cluster is running, you can easily manage its lifecycle using these native shortcuts:

- **Scale Up:** Add new nodes to `01-topology.yml`, then run:
  ```bash
  just scale
  ```

- **Remove a Node:** To gracefully remove a node (e.g., `worker1-k8s`):
  ```bash
  just remove-node worker1-k8s
  ```

- **Teardown (Destroy):** When you are finished and want to stop billing, run the destroy command. This gracefully uninstalls Kubernetes and deletes all GCP VMs and firewall rules.
  ```bash
  just destroy
  ```
