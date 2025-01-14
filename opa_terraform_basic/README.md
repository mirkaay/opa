# Create an Azure Service Principal

To allow Terraform to interact with your Azure resources securely, create a Service Principal.

## Install Azure CLI:

Download and install from [Azure CLI Install](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

## Login to Azure:

```bash
az login
```

Follow the browser prompts to authenticate.

## Create Service Principal:

```bash
$ az ad sp create-for-rbac -n MyApp --role Contributor --scopes /subscriptions/YOUR_SUBSCRIPTION_ID
```

Replace `YOUR_SUBSCRIPTION_ID` with your actual Azure subscription ID.

## Save the Output: 
The command will output JSON containing:
- `appId` (Client ID)
- `password` (Client Secret)
- `tenant`

### Example:
```json
{
  "appId": "YOUR_CLIENT_ID",
  "displayName": "terraform-sp",
  "password": "YOUR_CLIENT_SECRET",
  "tenant": "YOUR_TENANT_ID"
}
```

# Set Azure Environment Variables

Set the following environment variables to allow Terraform to authenticate with Azure.

Open terminal and run:

```bash
export ARM_CLIENT_ID="YOUR_CLIENT_ID"
export ARM_CLIENT_SECRET="YOUR_CLIENT_SECRET"
export ARM_SUBSCRIPTION_ID="YOUR_SUBSCRIPTION_ID"
export ARM_TENANT_ID="YOUR_TENANT_ID"
```

Replace the placeholders with your actual values from the Service Principal.

## Verify Environment Variables:

```bash
echo $ARM_CLIENT_ID
echo $ARM_CLIENT_SECRET
echo $ARM_SUBSCRIPTION_ID
echo $ARM_TENANT_ID
```

# Step 3: Install Terraform

## Download Terraform:

Visit the Terraform [downloads page](https://www.terraform.io/downloads.html) and download the appropriate binary for Windows.

## Install Terraform:

Extract the `terraform.exe` to a directory, e.g., `C:\Terraform\`.

## Add to System PATH:

Add the Terraform directory to your system's PATH following the same steps as for `kubectl`.

## Verify Installation:

```bash
terraform version
```

# Step 4: Write a Sample Terraform Configuration

Create a simple Terraform configuration to provision an Azure resource group.

## Directory for Terraform Files:

```bash
cd terraform-opa-azure
```

### Check main.tf:

## Initialize Terraform:

```bash
terraform init
```

## Generate a Terraform Plan:

```bash
terraform plan -out=tfplan
```

## Save the Terraform Plan as JSON:

```bash
terraform show -json tfplan > tfplan.json
```

# Step 5: OPA Rego Policies

Define policies to enforce compliance on your Terraform configurations. For example, restrict the creation of resource groups in specific locations.

## Navigate to Policies directory:

```bash
cd policies
```

### Check resource_group_location.rego

#### Explanation:
- **Package:** Defines the policy namespace.
- **allowed_locations:** A set of permitted Azure regions.
- **deny:** A rule that denies resource group creation if the location is not in the allowed list.

# Step 6: Integrate OPA with Terraform

Use OPA to evaluate Terraform plans against your policies before deployment.

## Install OPA CLI:

Download the latest OPA binary from the [OPA releases page](https://github.com/open-policy-agent/opa/releases).

Extract and move `opa.exe` to a directory in your system's PATH, e.g., `C:\OPA\`.

## Verify installation:

```bash
opa version
```

Ensure your Rego policies are in the 'policies' directory.

## Evaluate the Terraform Plan with OPA:

```bash
opa eval --data=policies --input=tfplan.json --explain=full "data.terraform.resource_group_location.deny"
```

- **Success Scenario:** If the Terraform plan complies with the policies, OPA returns an empty array.
- **Failure Scenario:** If there are policy violations, OPA returns the corresponding denial messages.

## Automate Policy Enforcement:
Incorporate the OPA evaluation step into your Terraform workflow to automatically block non-compliant deployments.