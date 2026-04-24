Overview
This task provisions a simple static website with services deployed by Terrraform

Structure

Terraform_static_site/

- main.tf # Connecting modules
- provider.tf # Configuration of provider
- backend.tf # Remote State (S3 + Dynamo)
- variables.tf # Defining variables
- terraform.tfvars # Giving values to variables
- outputs.tf # Outputs after applying
  - modules/
    - s3/
      - main.tf
      - variables.tf
      - versions.tf
    - cloudfront/
      - main.tf
      - variables.tf
      - versions.tf
  - website/
    - index.html

terraform init - initializing tf and creating .terraform directory
terraform plan - planning changes
terraform apply - planning again and after accepting infrastructure is created (s3 with website and cloudfront)
terraform destroy - clean up, deletes s3 with website and cloudfront, s3 with tfstate and dynamoDB table with lock have to be deleted manually
