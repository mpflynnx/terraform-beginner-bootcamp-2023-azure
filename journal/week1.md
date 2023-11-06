# <p align=center>Terraform Beginner Bootcamp 2023 Azure Week 1

## Week 1 Objectives.
The objectives of week 1 where:
- Change Terraform Cloud workspace to local execution mode.
- Understand the Terraform recommended 'Standard Module Structure' for the projects.
- Tag an existing Storage Account using a 'user_uuid' variable.
- Refactor the project into modules.
- Upload files to a storage account using Terraform.
- Create a Content Delivery Network with Azure Front Door.
- Assign a Web application Firewall (WAF) policy to Front Door.
- Automate Terraform with GitHub Actions
- Understand Data Sources.
- Understand the Lifecycle Meta Argument
- Implement content versioning
- Understand terraform_data resource type

<!-- <p align="center">

  <img src="../assets/week1.PNG"/>

</p>

# <p align=center>Week 1 Architecture Diagram </p> -->


# Table of Contents

- [Standard Module Structure](#standard-module-structure)
- [Refactor main.tf file](#refactor-maintf-file)
- [Terraform variables](#terraform-variables)
  - [Variables on the Command Line](#variables-on-the-command-line)
  - [Variable Definitions Files](#variable-definitions-files)
  - [Environment Variables](#environment-variables)
  - [Variable Definition Precedence](#variable-definition-precedence)
  - [Variable validation](#variable-validation)
  - [Tagging a storage account using a variable](#tagging-a-storage-account-using-a-variable)
- [Terraform Import](#terraform-import)
  - [Import with Terraform Cloud](#import-with-terraform-cloud)
  - [Configuration drift](#configuration-drift)
  - [Refresh state](#refresh-state)
- [Terraform Modules]()
  - [Module sources](#module-sources)
  - [Provider version constraints](#provider-version-constraints-in-modules)
  - [Using Terraform to upload files](#using-terraform-to-upload-files)
  - [Using Terraform to validate the existence of a file](#using-terraform-to-validate-the-existence-of-a-file)
- [Content Delivery Network](#content-delivery-network)
  - [Azure Front Door](#azure-front-door)
  - [Using Terraform to create an Azure Front Door Standard profile](#using-terraform-to-create-an-azure-front-door-standard-profile)
  - [Local Values](#local-values)
  - [Front Door Endpoint](#front-door-endpoint)
  - [Origins and Origin Groups](#origins-and-origin-groups)
  - [Routes](#routes)
- [Web Appllication Firewall (WAF)](#web-application-firewall-waf)
  - [WAF policy and rules](#waf-policy-and-rules)
  - [WAF modes](#waf-modes)
  - [WAF custom rules](#waf-custom-rules)
  - [IP restriction custom rule](#ip-restriction-custom-rule)
  - [Create a WAF policy using Terraform](#create-a-waf-policy-using-terraform)
  - [Security policy](#security-policy)
  - [Testing the WAF policy](#testing-the-waf-policy)
  - [Disable a WAF policy](#disable-a-waf-policy)
- [Automate Terraform with GitHub Actions](#automate-terraform-with-github-actions)
  - [Set up Terraform Cloud to use a GitHub Action](#set-up-terraform-cloud-to-use-a-github-action)
  - [Configure Terraform Cloud](#configure-terraform-cloud)
  - [Adding Workspace-specific Variables](#adding-workspace-specific-variables)
  - [Create an API Token](#create-an-api-token)
  - [Setting up the GitHub repository](#setting-up-the-github-repository)
  - [Create actions workflows](#create-actions-workflows)
  - [Destroying resources](#destroying-resources)
- [The lifecycle Meta-Argument](#the-lifecycle-meta-argument)
- [Trigger update by a variable change](#trigger-update-by-a-variable-change)
  - [The terraform_data Managed Resource Type](#the-terraform_data-managed-resource-type)


- [External References](#external-references)

## Terraform Cloud execution modes

By default Terraform Cloud sets the default execution mode to 'Remote'. This means plans and applies occur on Terraform Cloud's infrastructure. This is great for teams as developers can have the ability to review and collaborate on runs within the app. As a lone developer, the overhead of running on Terraform Clouds infrastructure may not be needed. Therefore 'local' mode is a good option. Plans and applies occur on out local machines under my control. Terraform Cloud is only used to store and synchronize state.

### Change the execution mode for a Terraform Cloud workspace
Previously I created a workspace in Terraform Cloud called 'terra-home-1', to change the execution mode I followed these steps:

- Login to Terraform Cloud account
- Navigate to Project - terraform-beginner-bootcamp-azure
- Navigate to Workspace - terra-home-1
- Click on Settings on the left hand pane
- Scroll down to Execution Mode
- Click on Custom
- Click on Local
- Scroll down and click Save Settings

## Standard Module Structure

In Terraform everything is a module, the main.tf is the root module and must exist in the root folder of the project. The standard module structure[<sup>[1]</sup>](#external-references) is a file and folder layout recommend by Terraform which allows for reusable modules distributed in separate repositories. Terraform tooling is built to understand the standard module structure and use that structure to generate documentation, index modules for the module registry, and more.

A minimal module should comprise of four files.

```
$ project root/
.
├── README.md
├── main.tf
├── variables.tf
├── outputs.tf
```

- README. This should be named README or README.md. This should be description of the module and it's use case.

- main.tf. This is the primary entrypoint. For a simple module, this may be where all the resources are created.
- variables.tf. This contains declarations for variables.
- outputs.tf. This contains declarations for outputs.
- providers.tf. This is optional, as some teams prefer to use the main.tf for provider configuration.

Terraform reads all *.tf files in the root folder.

## Terraform variables
I will create a 'user_uuid' variable and use it to tag my existing storage account. Terraform provides many ways for us to use variables.

Terraform variables also referred to as Input variables[<sup>[2]</sup>](#external-references) let you customise aspects of Terraform modules without altering the module's own source code.

When I declare variables in the root module of my configuration, I can set their values using CLI -var option, environment variables, a .tfvars file or in a Terraform Cloud workspace as Terraform variables.

The variables.tf is where the variable block should be defined.

### Variables on the Command Line

To specify individual variables on the [command line](https://developer.hashicorp.com/terraform/language/values/variables#variables-on-the-command-line), use the -var option when running the terraform plan and terraform apply commands:

```bash
$ terraform apply -var="user-uuid=256ceeb2-e547-42a5-af71-1556730567bd
```

### Variable Definitions Files
To set lots of variables, it is more convenient to specify their values in a [variable definitions file](https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files) (with a filename ending in either .tfvars or .tfvars.json) and then specify that file on the command line with -var-file. This is how Terraform Cloud passes workspace variables to Terraform.

```bash
$ terraform apply -var-file="dev.tfvars"
```

This is a good option for defining different variables for say development (dev.tfvars), and production (prod.tfvars).

Terraform automatically loads a number of variable definitions files if they are present:

- Files named exactly terraform.tfvars or terraform.tfvars.json.
- Any files with names ending in .auto.tfvars or .auto.tfvars.json.

#### terraform.tfvars example content

```bash
user_uuid = "256ceeb2-e547-42a5-af71-1556730567bd"
```

### Environment Variables
As a fallback for the other ways of defining variables, Terraform searches the environment of its own process for [environment variables](https://developer.hashicorp.com/terraform/language/values/variables#environment-variables) named TF_VAR_ followed by the name of a declared variable.

```bash
$ export TF_VAR_user_uuid="256ceeb2-e547-42a5-af71-1556730567bd"
```

### Variable Definition Precedence
Terraform loads variables in the following order, with later sources taking precedence over earlier ones:

- Environment variables
- The terraform.tfvars file, if present.
- The terraform.tfvars.json file, if present.
- Any *.auto.tfvars or *.auto.tfvars.json files, processed in lexical order of their filenames.
- Any -var and -var-file options on the command line, in the order they are provided. (This includes variables set by a Terraform Cloud workspace.)

**Note:** Files of type *.tfvars, *.tfvars.json are ignored and not stored in git version control.

### Variable validation

You can specify [custom validation rules](https://developer.hashicorp.com/terraform/language/values/variables#custom-validation-rules) for a particular variable by adding a validation block within the corresponding variable block. 
The example below checks whether the user_uuid has the correct syntax.

#### variables.tf

```
variable "user_uuid" {
  description = "The UUID for the user" 
  type = string

  validation {
    condition     = can(regex("^\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w{12}$", var.user_uuid))
    error_message = "Invalid UUID format. Please provide a valid UUID."
  }
}
```

### Tagging a Storage account using a variable

I have previously ran 'tf plan', and deployed a storage account. The state file is stored in Terraform Cloud.

I will tag the existing storage account with a variable named 'user_uuid'. The 'variables.tf' file defines and validates the value of the 'user_uuid' provided in the 'terraform.tfvars' file.

To add this tag I shall update the 'main.tf' files resource block with the tag block shown below.

####  main.tf
```tf
resource "azurerm_storage_account" "storage_account" {
  name = "terraformaccount202310"
  resource_group_name = azurerm_resource_group.resource_group.name
  location = azurerm_resource_group.resource_group.location
  account_tier = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"

  static_website {
    index_document = "index.html"
  }
    tags = {
    UserUuid = var.user_uuid
  }
}
```

Run the following commands to tag the storage account.

```bash
$ tf init
```
```bash
$ tf plan
```
```bash
$ tf apply --auto-approve
```

The tagging should complete successfully.

Check the tag of the storage account with the following Azure CLI command:

```bash
az storage account show -g terraform-beginner-bootcamp-2023-azure -n terraformaccount202310
```

#### Expected console output
The returned json should contain:

```json
..
"tags": {
    "UserUuid": "256ceeb2-e547-42a5-af71-1556730567bd"
  },
..
```

## Terraform Modules
Modules[<sup>[4]</sup>](#external-references) are containers for multiple resources that are used together. A module consists of a collection of .tf and/or .tf.json files kept together in a folder.

Modules are the main way to package and reuse resource configurations with Terraform.

I will refactor the project to use nested modules. I will create one module named 'terrahome_azure' and two nested modules, one for the storage resources and one for the content delivery resources.

```
$ project root/
.
├── README.md
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── modules/
   ├── terrahome_azure/
       ├── README.md
       ├── variables.tf
       ├── resource_storage.tf
       ├── resource_cdn.tf       
       ├── outputs.tf
       ├── LICENSE
```

Notice, that the root module must contain outputs.tf and variables.tf as well as the nested module 'terrahome_azure'. The variables and outputs need to be defined in the root module as well as the nested module.

## Data Sources
Data sources[<sup>[?]</sup>](#external-references) allow Terraform to use information defined outside of Terraform. Each provider may offer data sources alongside its set of resource types.

A data source is accessed via a special kind of resource known as a data resource, declared using a data block.

## Using Terraform to output the static website endpoint

To obtain a storage accounts static website primary endpoint. I shall use data source [azurerm_storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account).

#### example usage
```tf
data "azurerm_storage_account" "storage_data_source" {
  name = azurerm_storage_account.storage_account.name
  resource_group_name = azurerm_resource_group.resource_group.name
}
```

A data block requests that Terraform read from a given data source ("azurerm_storage_account") and export the result under the given local name ("storage_data_source"). The name is used to refer to this resource from elsewhere in the same Terraform module, but has no significance outside of the scope of a module.

For 'name' I need to define the storage account name. By defining the storage account name using expression references this will imply a dependency of the storage account on the data store.

for 'resource_group_name' I need to define the resource group of the storage account. By defining the resource group name using expression references this will imply a dependency of the resource group on the data source.

If I didn't use expression references, and the storage account and resource group did not exist when the data source block is run, then terraform plan command would fail.

With data sources I can use interpolation in the output block:

```tf
output "primary_web_endpoint" {
  description = "Storage accounts static website primary endpoint"
  value = data.azurerm_storage_account.storage_data_source.primary_web_endpoint
}
```

### Accessing Child Module Outputs
In a parent module, outputs of child modules are available in expressions as module.MODULE NAME.OUTPUT NAME. As shown below.

#### Root module outputs.tf example
```tf
output "storage_primary_web_endpoint" {
  description = "Storage accounts static website primary endpoint"
  value = module.terrahome_azure.primary_web_endpoint
}
```
Because the output values of a module are part of its user interface, you can briefly describe the purpose of each value using the optional 'description' argument.

#### Nested module outputs.tf example
```tf
output "primary_web_endpoint" {
  description = "Storage accounts static website primary endpoint"
  value = data.azurerm_storage_account.storage_data_source.primary_web_endpoint
}
```

### Declaring an Input Variable
Variables do not require validation at the root module level. Only validate at the nested module level.

#### Root module variables.tf example
```tf
variable "user_uuid" {
 description = "The UUID of the user"
 type = string
}
```

At the root and nested module level, you can briefly describe the purpose of each variable using the optional 'description' argument.

#### nested module variables.tf example
```tf
variable "user_uuid" {
  description = "The UUID of the user"
  type        = string
  validation {...not shown for brevity
  ...
  }
}
```

### Module Sources

The source[<sup>[5]</sup>](#external-references) argument in a module block tells Terraform where to find the source code for the desired child module.

Terraform uses this during the module installation step of terraform init to download the source code to a directory on local disk so that other Terraform commands can use it.

The module installer supports installation from a number of different source types.

- Local paths

- Terraform Registry

- GitHub

- Bitbucket

- Generic Git, Mercurial repositories

- HTTP URLs

- S3 buckets

- GCS buckets

- Modules in Package Sub-directories

#### Root module main.tf example using local path source type
```tf
terraform {
}

module "terrahome_azure" {
  source = "./modules/terrahome_azure"
  user_uuid = var.user_uuid
  resource_group_name = var.resource_group_name
  resource_group_location = var.resource_group_location
  storage_account_name = var.storage_account_name
  account_tier = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind = var.account_kind
}
```

A local path must begin with either ./ or ../ to indicate that a local path is intended, to distinguish from a module registry address.

### Provider Version Constraints in Modules

Although provider configurations[<sup>[6]</sup>](#external-references) are shared between modules, each module must declare its own provider requirements, so that Terraform can ensure that there is a single version of the provider that is compatible with all modules in the configuration and to specify the source address that serves as the global (module-agnostic) identifier for a provider.

To declare that a module requires particular versions of a specific provider, use a required_providers block inside a terraform block.


#### Nested module main.tf example
```tf
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.76.0"
    }
  }
}
```

A provider requirement says, for example, "This module requires version v3.76.0 of the provider hashicorp/azurerm and will refer to it as azurerm.

### Using Terraform to upload files

The Azure provider resource [azurerm_storage_blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob) can be used to upload files to a storage account blob. I can use this to upload the initial index.html and error.html files for my static website. Thereafter I shall use a separate repository and use GitHub Actions to upload any updates to the websites content. 

**Note:** It is best practice for Terraform to be used to provision cloud infrastructure only. Uploading files should be handled by another method or application in a production environment. I am using Terraform to upload the initial index.html and error.html only.

#### Example nested module resource block (provider version 3.76.0)

```tf
resource "azurerm_storage_blob" "index_html" {
  name = "index.html"
  storage_account_name = azurerm_storage_account.storage_account.name
  storage_container_name = "$web"
  type = "Block"
  content_type = "text/html"
  source = "${var.public_path}/index.html"
  content_md5 = filemd5("${var.public_path}/index.html")
}
```
It is best practice to define the content_type of the file, by using the [content_type](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob#content_type) argument.  Standard MIME types are supported. All Valid MIME Types are valid for this input. As I know my file contains html I shall use "text/html". Terraform can detect changes to the content_type argument.

By default, Terraform cannot detect any changes to a files contents. Therefore, I can add an [content_md5](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob#content_md5) to the file. The value will be the files md5 sum check. As the md5 sum check will change every time the file changes. Terraform does check for changes to content_md5.

Terraform has many [built-in functions](https://developer.hashicorp.com/terraform/language/expressions/function-calls). I will use the [filemd5](https://developer.hashicorp.com/terraform/language/functions/filemd5) function. 'filemd5' is a variant of md5 that hashes the contents of a given file rather than a literal string. This function will only accept UTF-8 text it cannot be used to create hashes for binary files.

### Using Terraform to validate the existence of a file

It is best practice to define files and file paths as Terraform variables. I can then validate the variable with a validation block in the nested modules variables.tf. 

The Terraform built-in function [fileexists](https://developer.hashicorp.com/terraform/language/functions/fileexists) checks that a file already exists on the disk.

I will store my file path as a variable in the terraform.tfvars file.

```
public_path="/workspace/terraform-beginner-bootcamp-2023-azure/public"
```

#### Example nested module variable block (Terraform version v1.5.x)

```tf
variable "public_path" {
  description = "The file path for index.html"
  type        = string

  validation {
    condition     = fileexists("${var.public_path}/index.html")
    error_message = "File index.html does not exist."
  }
}
```
Nested module variables must also be defined in the root module main.tf.

#### Example root module main.tf with nested module variable definition (Terraform version v1.5.x)
```tf
module "terrahome_azure" {
  source = "./modules/terrahome_azure"
  user_uuid = var.user_uuid
  resource_group_name = var.resource_group_name
  resource_group_location = var.resource_group_location
  storage_account_name = var.storage_account_name
  account_tier = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind = var.account_kind
  public_path = var.public_path
}
```

## Content Delivery Network

A content delivery network (CDN)[<sup>[?]</sup>](#external-references) is a network of interconnected servers that speeds up webpage loading for data-heavy applications. CDN can stand for content delivery network or content profile network. When a user visits a website, data from that website's server has to travel across the internet to reach the user's computer. If the user is located far from that server, it will take a long time to load a large file, such as a video or website image. Instead, the website content is stored on CDN servers geographically closer to the users and reaches their computers much faster.

### Azure Front Door

Azure Front Door[<sup>[?]</sup>](#external-references) is Microsoft’s modern cloud Content Delivery Network (CDN) that provides fast, reliable, and secure access between users and applications’ static and dynamic web content across the globe.

### Using Terraform to create an Azure Front Door Standard profile

To make my Terraform project folder more manageable, I will refactor my nested module main.tf into two separate files. One file (resource_storage.tf) will deal with the Azure storage account resources and the second file (resource_cdn.tf) will deal with the Azure Front Door resources.

#### Project folder after refactor
```
$ project root/
.
├── README.md
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── modules/
   ├── terrahouse_azure/
       ├── resource_cdn.tf
       ├── resource_storage.tf   
       ├── README.md
       ├── variables.tf
       ├── main.tf
       ├── outputs.tf
       ├── LICENSE
```


I want to use Front Door to distribute my content, so I first have to create a Front Door profile[<sup>[?]</sup>](#external-references). 

To create a Front Door profile I can use the Azure provider resource [azurerm_cdn_frontdoor_profile](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_profile).

Caution: Provider resources can change frequently, it is best practice to always refer to the latest documentation for the provider at registry.terraform.io

To create a profile I'm only required to provide a name, resource group and the sku_name.

#### resource_cdn.tf

```tf
resource "azurerm_cdn_frontdoor_profile" "my_front_door" {
  name                = local.front_door_profile_name
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard_AzureFrontDoor"
}
```

### Local Values

In the azurerm_cdn_frontdoor_profile resource block there is the following text 'local.front_door_profile_name'. This is known as a [Local Value](https://developer.hashicorp.com/terraform/language/values/locals) or 'Locals' in Terraform. A local value assigns a name to an expression, so you can use the name multiple times within a module instead of repeating the expression.

Local values are created by a locals block (plural), but you reference them as attributes on an object named local (singular).

A local value can only be accessed in expressions within the module where it was declared. Therefore the example below should appear in the same file but before the azurerm_cdn_frontdoor_profile resource block were it is accessed.

I will create more local values for use in resource_cdn.tf

#### resource_cdn.tf
```tf
resource "random_id" "front_door_endpoint_name" {
  byte_length = 8
}

locals {
  front_door_profile_name      = "MyFrontDoor"
  front_door_endpoint_name     = "afd-${lower(random_id.front_door_endpoint_name.hex)}"
  front_door_origin_group_name = "MyOriginGroup"
  front_door_origin_name       = "MyAppServiceOrigin"
  front_door_route_name        = "MyRoute"
}
```

For my local value front_door_endpoint_name I will use the [Random Provider - random_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) resource to help us create a unique name for my Front Door endpoint.

### Front Door Endpoint

In Azure Front Door, an [endpoint](https://learn.microsoft.com/en-us/azure/frontdoor/endpoint?tabs=azurecli) is a logical grouping of one or more routes that are associated with domain names. Each endpoint is assigned a domain name by Front Door, and I can associate my own custom domains by using routes.

I need to configure an endpoint for my Front Door profile. To do this I will use the [azurerm_cdn_frontdoor_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_endpoint) resource.

#### resource_cdn.tf
```tf
resource "azurerm_cdn_frontdoor_endpoint" "my_endpoint" {
  name                     = local.front_door_endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.my_front_door.id
}
```

Once again I will use a local 'front_door_endpoint_name' defined earlier for the endpoint name.

I can obtain the cdn_frontdoor_profile_id from the Front Door Profile within which this Front Door Endpoint should exists, i.e 'my_front_door'

### Origins and Origin Groups

An [origin](https://learn.microsoft.com/en-us/azure/frontdoor/origin?pivots=front-door-standard-premium#origin) refers to the application deployment that Azure Front Door retrieves contents from when caching isn't enabled or when a cache gets missed. The origin should be viewed as the endpoint for my application backend. In my case the origin will be the static website hostname.

An [origin group](https://learn.microsoft.com/en-us/azure/frontdoor/origin?pivots=front-door-standard-premium#origin-group) in Azure Front Door refers to a set of origins that receives similar traffic for their application. I can define the origin group as a logical grouping of my application instances across the world that receives the same traffic and responds with an expected behaviour. These origins can be deployed across different regions or within the same region. All origins can be deployed in an Active/Active or Active/Passive configuration.

An origin group defines how origins get evaluated by [health probes](https://learn.microsoft.com/en-us/azure/frontdoor/origin?pivots=front-door-standard-premium#health-probes). It also defines the [load balancing](https://learn.microsoft.com/en-us/azure/frontdoor/origin?pivots=front-door-standard-premium#load-balancing-settings) method between them.

Firstly, I need to create an origin group for my origin. I will use the [azurerm_cdn_frontdoor_origin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin_group) resource for this.

I need to provide a name for the origin group. I previously defined a local for this. I need to provide the profile id which I can retrieve from my my_front_door profile. I will use the default values for health probes and load balancing.

#### resource_cdn.tf
```tf
resource "azurerm_cdn_frontdoor_origin_group" "my_origin_group" {
  name                     = local.front_door_origin_group_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.my_front_door.id
  session_affinity_enabled = true

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {
    path                = "/"
    request_type        = "HEAD"
    protocol            = "Https"
    interval_in_seconds = 100
  }
}
```

Now I have the origin group defined, I need to create an origin. I will use the [azurerm_cdn_frontdoor_origin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin) resource for this.

I need to provide a name for the origin. I previously defined a local for this. I need to provide the origin group id which I can retrieve from my my_origin_group group.

Origin host name or host_name is where I provide the static website host name. I can retrieve this by using the primary_web_host attribute of [azurerm_storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#primary_web_host). In my case the Host name will be something like:

```
"terraformaccount202310.z33.web.core.windows.net"
```

I can define the [origin_host_header](https://learn.microsoft.com/en-us/azure/frontdoor/origin?pivots=front-door-standard-premium#origin-host-header). This is optional, as if unspecified the host_name is used. Requests that get forwarded by Azure Front Door to an origin include a host header field that the origin uses it to retrieve the targeted resource. Most app backends (Azure Web Apps, Blob storage, and Cloud Services) require the host header to match the domain of the backend. I will once again use the primary_web_host attribute of [azurerm_storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#primary_web_host), as this will match my host_name.

I will use the default values for the remaining arguments.

#### resource_cdn.tf
```tf
resource "azurerm_cdn_frontdoor_origin" "my_static_website_origin" {
  name                          = local.front_door_origin_name
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.my_origin_group.id

  enabled                        = true
  host_name                      = azurerm_storage_account.st.primary_web_host
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = azurerm_storage_account.st.primary_web_host
  priority                       = 1
  weight                         = 1000
  certificate_name_check_enabled = true
}
```

### Routes

A [route](https://learn.microsoft.com/en-us/azure/frontdoor/front-door-route-matching?pivots=front-door-standard-premium) maps my domains and matching URL path patterns to a specific origin group. [Learn more](https://learn.microsoft.com/en-us/azure/frontdoor/how-to-configure-endpoints)

I need to have at least one configured route in order for traffic to route between my domains.

Endpoint hostname is a DNS name that helps prevent subdomain takeover. This name is used to access my resources through my Azure Front Door profile.

The endpoint name specifies a desired subdomain on Front Door's default domain (i.e. .z01.azurefd.net) to route traffic from that host via Front Door.

#### validated domain example
```
afd-f699d40bf1f94020-ftdngdh3h8ehgkgj.z01.azurefd.net
```

I will use the [azurerm_cdn_frontdoor_route](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_route) resource for this.

I must provide argument values for name, cdn_frontdoor_endpoint_id, cdn_frontdoor_origin_group_id and cdn_frontdoor_origin_ids.

I previously defined a local for the route name 'front_door_route_name' I will use this for the route name. 

For cdn_frontdoor_endpoint_id, this is the resource ID of the Front Door Endpoint where this Front Door Route should exist. I will get this from my_endpoint. 

For cdn_frontdoor_origin_group_id. this is the resource ID of the Front Door Origin Group where this Front Door Route should be created. I will get this from my_origin_group.

For cdn_frontdoor_origin_ids, this is the Front Door Origin resource ID that this Front Door Route will link to. I will get this from my_static_website_origin. The value can be made up of multiple origin ids so the ids are to be within square brackets [] and separated by a comma.

patterns_to_match is the route pattern of the rule. Accepts all requests using /*

supported_protocols is the protocols to be supported by the route. I will support multiple hence using ["Http", "Https"]

I must define a validated domain that isn't associated with another route. I have a validated domain which is the endpoint hostname of the Azure Front Door profile. I set [link_to_default_domain](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_route#link_to_default_domain) to true to link to the endpoint.

https_redirect_enabled, this is a [rule](https://learn.microsoft.com/en-us/azure/frontdoor/front-door-rules-engine?pivots=front-door-standard-premium) and is the first to be executed. A Rule set can be used to allow customisation of how requests get processed and handled at the Azure Front Door edge. I will not define a rule set. I will however enable this rule to redirect all traffic to use HTTPS.

#### resource_cdn.tf
```tf
resource "azurerm_cdn_frontdoor_route" "my_route" {
  name                          = local.front_door_route_name
  # depends_on = [ azurerm_cdn_frontdoor_origin.my_static_website_origin] // This explicit dependency is required to ensure that the origin group is not empty when the route is created.
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.my_endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.my_origin_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.my_static_website_origin.id]

  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = ["/*"]
  forwarding_protocol    = "HttpsOnly"
  link_to_default_domain = true
  https_redirect_enabled = true
}
```

## Web Application Firewall (WAF)

[Web Application Firewall (WAF)](https://learn.microsoft.com/en-us/azure/web-application-firewall/) provides centralised protection of web applications from common exploits and vulnerabilities. I can deploy [WAF on Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/afds-overview).

Azure Web Application Firewall is natively integrated with Azure Front Door Premium with full capabilities.
As I previously created a Azure Front Door profile using the Standard tier, I can only use custom rules.

### WAF policy and rules

I shall configure a WAF policy and associate that policy to my Azure Front Door domains for protection. A WAF policy consists of two types of security rules:

- Custom rules that the customer created. (Standard or Premium tier)
- Managed rule sets that are a collection of Azure-managed preconfigured sets of rules. (Premium tier only)

### WAF modes

I can configure my WAF policy to run in two modes:

- Detection: When a WAF runs in detection mode, it only monitors and logs the request and its matched WAF rule to WAF logs. It doesn't take any other actions. You can turn on logging diagnostics for Azure Front Door. When you use the portal, go to the Diagnostics section.
- Prevention: In prevention mode, a WAF takes the specified action if a request matches a rule. If a match is found, no further rules with lower priority are evaluated. Any matched requests are also logged in the WAF logs.

### WAF custom rules
Our WAF policy will consist of custom security rule.

I can configure [custom rules](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/afds-overview#custom-authored-rules) for a WAF, using the following controls:

- IP allow list and block list.
- Geographic-based access control.
- HTTP parameters-based access control.
- Size constraint.
- Rate limiting rules.

### IP restriction custom rule

For this project and ease of demonstration and testing, I shall create a IP restriction custom rule. The rule will when enabled, allow only one IP address to access the Azure Front Door domain all other addresses will receive a 403 forbidden response.

### Create a WAF policy using Terraform

I will create a new configuration file named 'resource_security.tf' in my terrahome_azure module, here I shall create the WAF policy.

To create a WAF policy using Terraform I can use [azurerm_cdn_frontdoor_firewall_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_firewall_policy). This resource is dependent upon Azure resource group and Azure Front Door Profile resources.

Our policy shall contain one custom rule named 'FdWafCustRule'. This rule will only allow one IP address to access my Front Door Domain. I am doing this to best demonstrate how a WAF policy works. The allowed IP address will be my public IP address. I can find my public IP address from [dnsleaktest.com](https://dnsleaktest.com/). My public IP address may change frequently so best to check frequently.

I will store the IP address as an environmental variable named 'TF_VAR_my_ip_address'. Substitute the fake IP address with my IP address.

```bash
export TF_VAR_my_ip_address="12.345.678.910" # fake IP address
gp env TF_VAR_my_ip_address="12.345.678.910" # fake IP address
```

I must now define the new variable in the root modules variables.tf files as well as the nested module terrahome_azure variables.tf

#### variables.tf
```tf
...

variable "my_ip_address" {
  type        = string
  description = "my external ip address"  
}
```

The root module main.tf also needs updating as shown.

```tf
...

module "terrahome_azure" {
  source = "./modules/terrahome_azure"
  ...
  my_ip_address = var.my_ip_address
}
```

I can then reference the variable in my waf policy resource block.

#### resource_security.tf
```tf
locals {
  waf_policy_name      = "wafpolicy1"
}

resource "azurerm_cdn_frontdoor_firewall_policy" "my_waf_policy" {
  name                              = local.waf_policy_name
  resource_group_name               = azurerm_resource_group.rg.name
  sku_name                          = azurerm_cdn_frontdoor_profile.my_front_door.sku_name
  enabled                           = true
  mode                              = "Prevention"
  custom_block_response_status_code = 403
 
  custom_rule {
    name                           = "FdWafCustRule"
    enabled                        = true
    priority                       = 100
    rate_limit_duration_in_minutes = 1
    rate_limit_threshold           = 100
    type                           = "MatchRule"
    action                         = "Block"

    match_condition {
      match_variable     = "SocketAddr"
      operator           = "IPMatch"
      negation_condition = true
      match_values       = [var.my_ip_address] 
    }
  }
}
```

### Security policy

Now I have created a WAF policy I need to associate it with my Front Door profile and domain. I do this using a Security policy.

A security policy includes a web application firewall (WAF) policy and one or more domains to provide centralised protection.

To create a security policy using Terraform I can use [azurerm_cdn_frontdoor_security_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_security_policy).

For this I need to provide a security policy name which must be unique within the Front Door. I will use the random provider to generate a random name for the policy.

#### resource_security.tf
```tf
resource "random_id" "security_policy_name" {
  byte_length = 16
}

locals {
  ...
  security_policy_name     = "${lower(random_id.security_policy_name.hex)}"
}
```

I also need to provide the Front Door policy ID, WAF policy ID and domain ID.

#### resource_security.tf
```tf
resource "azurerm_cdn_frontdoor_security_policy" "my_security_policy" {
  name                     = local.security_policy_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.my_front_door.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.my_waf_policy.id

      association {
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.my_endpoint.id
        }
        patterns_to_match = ["/*"]
      }
    }
  }
}
```

### Testing the WAF policy

I should be able to browse to my Front Door endpoint hostname with no errors, as I am only allowing one IP address to access this hostname. I can test the WAF policy by changing the environmental variable 'my_ip_address' to the fake IP address, as shown below.

```bash
export TF_VAR_my_ip_address="12.345.678.910" # Use the fake IP address
```

- Rerun the terraform plan command, and note the one change to the WAF policy is the change to the IP address.
- Run the terraform apply command to update the WAF policy.
- Wait a few minutes for the updated policy to become activated.
- Navigate to the Front Door endpoint hostname. You should be presented with something similar to that shown below.

```
The request is blocked.


20231101T121751Z-vkbq9r28ex7w71h17z09f06b1c00000005eg00000000qrdz   
```

You have successfully implemented and tested a WAF policy.

### Disable a WAF policy
Going forward, I do not need to implement this WAF policy, so I shall disable it. I can do this by changing 'enabled' argument value to 'false' for the policy.

```tf
resource "azurerm_cdn_frontdoor_firewall_policy" "my_waf_policy" {
  
  ...

  enabled                           = false

  ...
}
```

Rerun terraform apply, to implement this.

## Automate Terraform with GitHub Actions

Currently I have been running Terraform in my development environment. I have now setup the infrastructure and have successfully tested the deployment using Terraform. Going forward, I plan to use GitHub Actions to run a Terraform Plan and a Terraform Apply should I need to amend the infrastructure.

GitHub Actions add continuous integration to GitHub repositories to automate software builds, tests, and deployments. Automating Terraform with CI/CD enforces configuration best practices, promotes collaboration, and automates the Terraform workflow.

HashiCorp provides GitHub Actions that integrate with the Terraform Cloud API. These actions let me create my own custom CI/CD workflows to meet my needs.

I will use HashiCorp's Terraform Cloud GitHub Actions to create a complete Actions workflow to deploy Azure infrastructure within a Terraform Cloud workspace.

The workflow will:

- Generate a plan for every commit to a pull request branch, which I can review in Terraform Cloud.
- Apply the configuration when I update the main branch.

By using HashiCorp's Terraform Cloud GitHub Actions, I can create a custom workflow with additional steps before or after my Terraform operations.

### Set up Terraform Cloud to use a GitHub Action

The GitHub Action will connect to Terraform Cloud to plan and apply my configuration. Before I set up the Actions workflow, I must create a workspace, add my Azure credentials to the Terraform Cloud workspace, and generate a Terraform Cloud user API token.

### Configure Terraform Cloud
Go to [Terraform Cloud login](https://app.terraform.io/session)
1. Login to Terraform Cloud account.
1. Create a new [organization](https://app.terraform.io/app/organizations/new).
1. Create a new  API-driven workflow [workspace](https://app.terraform.io/app/mpflynnx/workspaces/new).
1. Give Workspace Name as terrahome. The name of the workspace is unique and used in tools, routing, and UI. Dashes, underscores, and alphanumeric characters are permitted. Learn more about [naming workspaces](https://www.terraform.io/docs/cloud/workspaces/naming.html)

1. Select Project 'terraform-beginner-bootcamp-azure'. Give description of the workspace. Then click Create workspace.

### Adding Workspace-specific Variables

1. Open a browser tab and login to [Terraform cloud account](https://app.terraform.io/session).
1. Go to workplace 'terrahome'.
1. Click Variables on left hand pane.
1. Scroll down to Workspace variables.
1. Open another browser tab and login to my [Gitpod account](https://gitpod.io/login/).
1. Go to Gitpod, User settings, then click [Variables](https://gitpod.io/user/variables). Here are the Azure credentials I added to my Gitpod account previously. I will copy them from here to the Terraform Cloud workspace.
1. Go back onto the Terraform Cloud 'terrahome' workspace browser tab.
1. Click + Add variable.
1. Choose the variable category as environment.
1. Create a new variable with key ARM_CLIENT_ID, copy the value from the Gitpod user settings browser tab.
1. Mark the variable as sensitive. This prevents Terraform from displaying it in the Terraform Cloud UI and makes the variable write-only.
1. Click Add variable.
1. Repeat steps 8 to 12 for the remaining three ARM_ variables.
1. I have now added my Service Principal credentials to the 'terrahome' workspace.
1. Check that all variables have Category of 'env' and the value is marked as 'Sensitive - write only'.

### Create an API Token

1. Click on [Tokens](https://app.terraform.io/app/settings/tokens).

1. Click on Create an API token. Give a description as 'GitHub Actions terrahome'. Set Expiration to 30 days. Click Generate Token.

1. Copy the Token now, as you will not be able to see it again, if you close the [Tokens](https://app.terraform.io/app/settings/tokens) browser tab.

### Setting up the GitHub repository

1. Open a browser tab at the repository

1. In the repository, navigate to the Settings page. Open the Secrets and variables menu, then select Actions.

1. Now, select New repository secret. 
1. Create a secret named TF_API_TOKEN
1. Paste the Terraform Cloud API token you copied in the previous step as the value.

### Create actions workflows

Inside the repositories root folder open a terminal and run the following command to create a new folder:

```bash
mkdir -p .github/workflows
```
I will download template workflow files from the hashicorp-education organisations, [learn-terraform-github-actions](https://github.com/hashicorp-education/learn-terraform-github-actions) repository.

Change to the workflow folder and run the following commands to create the action workflow yaml files by 

```bash
curl -O https://raw.githubusercontent.com/hashicorp-education/learn-terraform-github-actions/main/.github/workflows/terraform-apply.yml
```

```bash
curl -O https://raw.githubusercontent.com/hashicorp-education/learn-terraform-github-actions/main/.github/workflows/terraform-plan.yml 
```

Edit the env: section of the two files. Replacing the  "YOUR-ORGANIZATION-HERE" and "learn-terraform-github-actions" with the name of the Terraform Cloud organization and workspace name respectively.

Then, the configuration defines a terraform job, and grants the workflow permission to read the repository contents and write to pull requests.

Now a Pull Request will trigger the Terraform Plan Actions workflow. When the workflow completes, it will add a comment with a link to the speculative plan. Click the Terraform Cloud Plan link to view the plan in Terraform Cloud.

Merge the pull request.

Click on the Terraform Apply workflow.

Wait for the workflow to complete.

Then, expand the Apply step, scroll to the bottom, and click the link next to View Run in Terraform Cloud.

In Terraform Cloud, expand the Apply finished section. Terraform Cloud shows any resources it changed/created, and the Terraform outputs.

### Destroying resources

Now that I have provisioned and changed infrastructure with Terraform Cloud, a final stage of my infrastructure's lifecycle maybe to destroy it. Terraform Cloud allows me to destroy the infrastructure I have provisioned as a part of the standard workflow.

- Go to the Terraform Cloud workspace settings
- Then to Destruction and Deletion. 
- Click Queue destroy plan.
- Enter my workspace name and queue the plan.
- Confirm and Apply the plan. This destroys all infrastructure managed by the workspace.

## The lifecycle Meta-Argument
By using the [lifecycle Meta-Argument](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle#syntax-and-arguments) I can prevent Terraform from automatically making changes to the infrastructure.

Currently, when I update the public/index.html file of my project and run a 'terraform plan' command, Terraform picks up the change to the index.html files content_md5, and will plan to upload the new version of the file. To have better control of when the file should be updated on the infrastructure I can use a lifecycle block and use [ignore_changes](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle#ignore_changes) on the content_md5 of files.

#### resource_storage.tf
```tf
resource "azurerm_storage_blob" "index_html" {
  ..
  ..
  lifecycle {
    ignore_changes = [ content_md5 ]
  }
}
```

## Trigger update by a variable change
As I will be managing the content of the static website via another repository. I do not want Terraform to make a change to this content. As Terraform is used to set the initial index.html and error.html files. I do not want any updates provisioned by the state website content repository to be changed by this repository. I would like the 'terraform plan' command to only plan to update the index.html and error.html file when a variable changes.

I will create a new variable called 'content_version' this variable will store only positive integers greater than zero.

#### Nested module variables.tf with validation
```tf
variable "content_version" {
  type        = number
  description = "Content version number"
  default     = 1
  validation {
    condition     = var.content_version > 0 && can(var.content_version)
    error_message = "Content version must be a positive integer"
  }
}
```

I will update the root modules variables.tf and main.tf accordingly.

#### root module main.tf additions
```tf
module "terrahome_azure" {
  source = "./modules/terrahome_azure"
  ..
  content_version = var.content_version
}
```

#### root module variables.tf additions
```tf
..

variable "content_version" {
  description = "Content version number"
  type        = number
}
```

As I'm using a local terraform.tfvars file for variables, I will set a valid value for the variable in this file.

#### Root module terraform.tfvars
```tf
content_version = 1
```

### The terraform_data Managed Resource Type

I will use the [terraform_data](https://developer.hashicorp.com/terraform/language/resources/terraform-data) resource as a means to keep track of the 'content_version' variable. 

The terraform_data resource implements the standard resource lifecycle, but does not directly take any other actions. You can use the terraform_data resource without requiring or configuring a provider.

The terraform_data resource is useful for storing values which need to follow a managed resource lifecycle, and for triggering provisioners when there is no other logical managed resource in which to place them.

To use terraform_data I will create a new resource block in my nested modules resource_storage.tf file.

#### resource_storage.tf
```tf
resource "terraform_data" "content_version" {
  input = var.content_version
}
```

I can now use this resource inside the lifecycle block to trigger on changes to the variable 'content_version'.

By using the lifecycle [replace_triggered_by](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle#replace_triggered_by) argument, I can trigger replacements when a change to the input value of resource 'content_version' occurs.

Therefore, 'terraform plan' will ignore changes to a files content_md5, but it will plan to update the file, if the files content_md5 has changed and the 'content_version' variable has changed.

#### resource_storage.tf
```tf
resource "azurerm_storage_blob" "index_html" {
  ..
  ..
  lifecycle {
    replace_triggered_by = [ terraform_data.content_version ]
    ignore_changes = [ content_md5 ]
  }
}
```


## External References
- [Standard Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure) <sup>[1]</sup>
- [Input Variables](https://developer.hashicorp.com/terraform/language/values/variables) <sup>[2]</sup>
- [Terraform Modules](https://developer.hashicorp.com/terraform/language/modules) <sup>[4]</sup>
- [Module Sources](https://developer.hashicorp.com/terraform/language/modules/sources) <sup>[5]</sup>
- [Provider Version Constraints in Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers#provider-version-constraints-in-modules) <sup>[6]</sup>
- [Configure an IP restriction rule with a WAF for Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-configure-ip-restriction)
- [Azure Web Application Firewall on Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/afds-overview)