# Infrastructure as Code for "Starfleet Enterprise" on Azure

This project uses [OpenTofu](https://opentofu.org/) to define and manage a complete infrastructure environment on Microsoft Azure. It follows Infrastructure as Code (IaC) best practices, integrating with [OpenBao](https://openbao.org/) for secure secret management.

The infrastructure includes core networking, virtual machines, identity management with Azure Active Directory (Entra ID), and security components like Key Vault and monitoring.

## Technologies Used

*   **OpenTofu (v1.6+)**: The core IaC tool for defining and deploying infrastructure.
*   **Azure**: The target cloud platform.
    *   `azurerm` provider: For managing Azure resources (VMs, networking, etc.).
    *   `azuread` provider: For managing Azure Active Directory resources (users, groups, etc.).
*   **OpenBao (Vault)**: For securely storing and retrieving sensitive credentials like service principal secrets.
*   **Azure CLI**: For authentication and ad-hoc Azure commands.
*   **Docker**: For running a local OpenBao instance for development.

## Prerequisites

Before you begin, ensure you have the following installed and configured:

1.  **OpenTofu CLI**: [Installation Guide](https://opentofu.org/docs/intro/install/)
2.  **Azure CLI**: [Installation Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
3.  **Docker**: [Installation Guide](https://docs.docker.com/get-docker/)
4.  **An Azure Subscription**.
5.  **An Azure Service Principal (SPN)** with the following permissions:
    *   **Azure RBAC Role**: `Contributor` on your subscription.
    *   **Azure RBAC Role**: `User Access Administrator` on the resource group (`rg-starfleet-enterprise-prod`) to manage role assignments.
    *   **Microsoft Graph API Permissions** (granted via "API permissions" in the App Registration):
        *   `User.ReadWrite.All`
        *   `Group.ReadWrite.All`
        *   `Policy.ReadWrite.ConditionalAccess`

## Setup and Configuration

Follow these steps to set up your environment to run this project.

### 1. Clone the Repository

```bash
git clone <your-repository-url>
cd <your-repository-directory>
```

### 2. Start and Configure OpenBao

This project uses OpenBao to manage secrets.

```bash
# Start the OpenBao container in development mode
sudo docker run --cap-add=IPC_LOCK -p 8200:8200 --name openbao -d openbao/openbao-dev:1.21

# Set environment variables to connect to OpenBao (replace token if necessary)
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='<your-root-token>' # Use the root token from your container logs

# Enable the Key/Value (kv) secrets engine
docker exec openbao vault secrets enable kv

# Store your Azure Service Principal credentials in OpenBao
# (Ensure these variables are set in your terminal first)
docker exec openbao vault kv put kv/starfleet/dev/azure_spn \
  client_id="$ARM_CLIENT_ID" \
  client_secret="$ARM_CLIENT_SECRET" \
  tenant_id="$ARM_TENANT_ID" \
  subscription_id="$ARM_SUBSCRIPTION_ID"
```

### 3. Configure Azure Backend Credentials

OpenTofu needs to authenticate to your Azure backend *before* it can read from OpenBao. Export your service principal credentials in your terminal.

```bash
export ARM_CLIENT_ID="<your-spn-client-id>"
export ARM_CLIENT_SECRET="<your-spn-client-secret>"
export ARM_TENANT_ID="<your-spn-tenant-id>"
export ARM_SUBSCRIPTION_ID="<your-subscription-id>"
```

### 4. Configure OpenTofu Backend

Ensure your `backend.tf` file is correctly configured with the details of the Azure Storage Account where the OpenTofu state will be stored.

```hcl
# backend.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-starfleet-tofu-state"
    storage_account_name = "ststarfleettofustate"
    container_name       = "tfstate-prod"
    key                  = "terraform.tfstate"
  }
}
```

## Usage

Follow the standard OpenTofu workflow to manage your infrastructure.

1.  **Initialize OpenTofu**
    *   Run this once at the beginning or if you add a new provider.
    ```bash
    tofu init
    ```

2.  **Plan Changes**
    *   Run this every time you make a change to see a preview of the actions OpenTofu will take.
    ```bash
    tofu plan
    ```

3.  **Apply Changes**
    *   Run this to execute the plan and build/modify your infrastructure.
    ```bash
    tofu apply
    ```

4.  **Destroy Infrastructure**
    *   To tear down all resources managed by this configuration, run:
    ```bash
    tofu destroy
    ```

## File Structure

The project is organized into the following files, each with a specific responsibility:

*   `main.tf`: Core provider configurations, data sources, and the main resource group.
*   `versions.tf`: Specifies the required provider versions.
*   `provider.tf`: Configures the `azurerm` provider.
*   `backend.tf`: Configures the remote backend for state storage.
*   `network.tf`: Defines the Virtual Network, subnets, and Network Security Groups.
*   `compute.tf`: Defines the virtual machine, public IP, and network interface.
*   `data_security.tf`: Defines the Azure Key Vault, secrets, and access policies.
*   `identity.tf`: Defines Azure AD users and groups.
*   `policy.tf`: Defines security policies, such as Azure AD Named Locations.
*   `monitoring.tf`: Defines the Log Analytics Workspace and diagnostic settings.
