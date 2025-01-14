# Explanation:
GitHub Actions file must be stored under .github/workflows/terraform.yml in your repository

- **Checkout Code:** Retrieves your repository code.
- **Set up Terraform:** Installs the specified Terraform version.
- **Install OPA:** Downloads and installs the OPA CLI.
- **Terraform Init:** Initializes Terraform.
- **Terraform Plan:** Generates a Terraform plan.
- **Terraform Show JSON:** Converts the plan to JSON.
- **OPA Policy Check:** Evaluates the plan against OPA policies. If violations are found, the pipeline fails.
- **Terraform Apply:** Applies the Terraform plan if on the main branch and no violations are detected.

# Configure Secrets:

In your GitHub repository, navigate to Settings > Secrets and variables > Actions.  
Add the following secrets with your Azure Service Principal details:

- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`