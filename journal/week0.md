# <p align=center>Terraform Beginner Bootcamp 2023 Week 0

## Week 0 Objectives.
The objectives of week 0 where:
- Create an Azure Service Principal for the project.
- Register and setup Gitpod development environment
- Customise the Gitpod development environment with installation scripts for Terraform CLI and Azure CLI applications
- Register a Terraform Cloud account.
- Setup Terraform Cloud, create new project and workspace.
- Setup Terraform Cloud workspace variables for Azure Service Principal.
- Use Terraform Random Provider to generate a unique Azure Storage account  name.
- Use Terraform Azure provider to provision an Azure Storage account and blob storage.
- Terraform state file stored safely in Terraform Cloud.


<p align="center">
  <img src="../assets/week0.PNG"/>
</p>

# <p align=center>Week 0 Architecture Diagram </p>

# Table of Contents

- [Project Git flow](#project-git-flow)
- [Semantic Versioning](#semantic-versioning)
- [Gitpod development platform](#gitpod-development-platform)
  - [Execution order](#execution-order)
  - [Wait for commands to complete](#)
  - [Restart a Workspace](#restart-a-workspace)
- [Terraform](#terraform)
  - [Terraform providers](#terraform-providers)
  - [Terraform modules](#terraform-providers)
- [Terraform CLI](#terraform-cli)
  - [Installation of Terraform CLI in Gitpod workspace](#installation-of-terraform-cli-in-gitpod-workspace)
  - [Bash script files](#bash-script-files)
  - [Script file execution](#script-file-execution)
  - [File permissions](#file-permissions)
  - [File protection](#file-protection)
  - [install_terraform_cli script](#install_terraform_cli-script)
  - [Refactor the .gitpod.yml file](#refactor-the-gitpodyml-file-for-install_terraform_cli)
  - [Refactor Terraform installation script](#refactor-terraform-installation-script)
  - [Environmental variables](#environmental-variables)
  - [Gitpod environmental variables](#gitpod-environmental-variables)
  - [Terraform CLI fundamentals](#terraform-cli-fundamentals)
  - [Cloud provider resource names](#cloud-provider-resource-names)
  - [A simple main.tf example](#a-simple-maintf-example)
  - [Terraform basic usage example](#terraform-basic-usage-example)
  - [Terraform files and version control](#terraform-files-and-version-control)
- [Azure CLI](#azure-cli)
  - [Installation of Azure CLI in Gitpod workspace](#installation-of-azure-cli-in-gitpod-workspace)
  - [install_azure_cli script](#install_azure_cli-script)
  - [Refactor the .gitpod.yml file for install_azure_cli](#refactor-the-gitpodyml-file-for-install_azure_cli)
- [Terraform and Azure](#terraform-and-azure)
  - [Authentication and Configuration](#authentication-and-configuration)
  - [Service Principal](#service-principal)
  - [Creating a Service Principal](#creating-a-service-principal-using-the-azure-cli)
  - [Adding Service Principal credentials to Gitpod workspace](#adding-service-principal-credentials-to-gitpod-workspace)
  - [Test the Service Principal credentials](#test-the-service-principal-credentials)
- [Azure storage account](#azure-storage-account)
  - [Creating a storage account](#creating-a-storage-account)
  - [Creating a resource group with Terraform](#creating-a-resource-group-with-terraform)
  - [Creating a general-purpose v2 storage account with Terraform](#creating-a-general-purpose-v2-storage-account-with-terraform)
  - [Creating blob storage with Terraform](#creating-blob-storage-with-terraform)
  - [Testing Terraform configuration](#testing-terraform-configuration)
  - [Check infrastructure](#check-infrastructure)
  - [Destroy infrastructure](#destroy-infrastructure) 
- [Terraform Cloud](#terraform-cloud)
  - [Terraform Cloud pricing](#terraform-cloud-pricing)
  - [Register for a new Terraform Cloud account](#register-for-a-new-terraform-cloud-account)
  - [Configure Terraform Cloud](#configure-terraform-cloud)
  - [Create an API Token](#create-an-api-token)
  - [Gitpod problems with Terraform login command](#gitpod-problems-with-terraform-login-command)
  - [generate_tfrc_credentials bash script](#generate_tfrc_credentials-bash-script)
  - [Terraform Cloud Workspace variables](#terraform-cloud-workspace-variables)
  - [Adding Workspace-specific Variables](#adding-workspace-specific-variables)
  - [Terraform Cloud setup confirmation](#terraform-cloud-setup-confirmation)
- [Terraform cli convenience bash alias](#terraform-cli-convenience-bash-alias)
- [External References](#external-references)
  

## Project Git flow

This project is going to utilise the issue, feature branch, pull request, tag GitHub workflow.

Issues should be created in GitHub. Then feature branches created to work on the issue.
Pull requests are to be used to merge the completed feature branch into main branch. Then the main branch tag is updated using semantic versioning.

## Semantic Versioning

This project is going to utilise semantic versioning for its tagging.

[semver.org](https://semver.org/)

The general format:

**MAJOR.MINOR.PATCH**, eg `1.0.1`

- **MAJOR** version when you make incompatible API changes
- **MINOR** version when you add functionality in a backward compatible manner
- **PATCH** version when you make backward compatible bug fixes
Additional labels for pre-release and build metadata are available as extensions to the MAJOR.MINOR.PATCH format.

## Gitpod development platform

This project shall utilise the [Gitpod](https://www.gitpod.io/) development platform.

The environment is built for the project by defining tasks in the [.gitpod.yml](.gitpod.yml) configuration file.

With Gitpod, you have the following three types of [tasks](https://www.gitpod.io/docs/configure/workspaces/tasks):

### Execution order

- before: Use this for tasks that need to run before init and before command. For example, customize the terminal or install global project dependencies.
- init: Use this for heavy-lifting tasks such as downloading dependencies or compiling source code.
- command: Use this to start your database or development server.

### Wait for commands to complete

When working with multiple terminals, you may have a situation where terminal 1 runs build scripts and terminal 2 and 3 require that these scripts complete first. This can be achieved with gp sync-await and gp sync-done.

As I have multiple scripts using the apt package manager. apt creates a lock file while it's in use, therefore any other scripts using apt will fail.

I wanted the install_terraform_cli script to finish before any other scripts are run. To achieve this I used the [gp sync-done](https://www.gitpod.io/docs/references/gitpod-cli#sync-done) command after the install_terraform_cli is run.


```yaml
gp sync-done terraform-cli
```
I then used [gp sync-await](https://www.gitpod.io/docs/references/gitpod-cli#sync-await) command before running any other scripts.

```yaml
gp sync-await terraform-cli
```

### Restart a Workspace
When you restart a workspace, Gitpod already executed the init task either as part of a Prebuild or when you started the workspace for the first time. The init task will not be
run when the workspace is restarted. Gitpod executes the before and command tasks on restarts. **It is recommended to use the before task not the init task.**

## Terraform

Terraform is an infrastructure as code tool. Terraform is a command line interface application written in GO. Terraform is cloud agnostic. We can learn it once and then use it to provision cloud resources on multiple different cloud providers. Terraform is able to store the state of the resources deployed. We can make changes to them or add new resources, without needing to repeat deployment. Terraform is configured by using a declarative file format known as HCL.

### Terraform providers

Terraform plugins called providers let Terraform interact with cloud platforms and other services via their application programming interfaces (APIs). You can find providers for many of the platforms and services like Azure and AWS in the [Terraform Registry Providers section](https://registry.terraform.io/browse/providers).

The Terraform documentation is a great resource, with many examples. It should be consulted often when writing HCL for your chosen provider.

- [Terraform Azure provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)


### Terraform modules

Modules are templates for commonly used actions, they are self-contained packages of Terraform configurations that are managed as a group. You can find modules for many of the platforms and services like AWS and Azure in the [Terraform Registry Modules section](https://registry.terraform.io/browse/modules)

## Terraform CLI

To use Terraform you will need to install it. HashiCorp distributes Terraform as a binary package. You can also install Terraform using popular package managers.

The Gitpod workspace is built on the Ubuntu 22.04.3 LTS Operating system.

To confirm the workspace operating system. You can use the following linux command in a bash terminal in the running Gitpod workspace.

```
$ cat /etc/os-release
```

Expected console output:
```
PRETTY_NAME="Ubuntu 22.04.3 LTS"
NAME="Ubuntu"
VERSION_ID="22.04"
VERSION="22.04.3 LTS (Jammy Jellyfish)"
VERSION_CODENAME=jammy
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=jammy
```

### Installation of Terraform CLI in Gitpod workspace

The commands needed to install Terraform CLI are for Linux Ubuntu/Debian are described [here](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform).

As there are multiple command lines needed to install Terraform CLI, we shall not clutter the .gitpod.yml with these commands, but shall create a bash script.

### Bash script files 

A bash script is identified by it's first line.

Typically:

```bash
#!/bin/bash
```

This is known as a [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)), pronounced sha-bang. 
```bash
#!
```

As best practice all bash script files should have the command below as the first line.

```bash
#!/usr/bin/env bash
```

This allows portability for running the script on different linux operating systems where the bash command location may be located somewhere other than /bin/bash.

### Script file execution
To execute a bash script in the terminal you can prepend the script filename with the word source.
```
source ./install_terraform_cli
```

```
./
```
The above relates to the relative path of the script file.
The terminal prompt should be in the same folder as the script file. Alternatively you can
add the file path to the command.

```
$ source ./bin/install_terraform_cli
```

The source command has permission to run bash scripts, irrespective of the scripts linux permissions.

### File permissions
To run a bash script **without** using the source command. The file needs to have it's executable bit set. By default all newly created files are not
executable.

To find the current [permissions](https://en.wikipedia.org/wiki/File-system_permissions) of a file use:

```bash
$ ls -la ./script-filename
```
Expected console output:
```
0 -rw-r--r-- 1 gitpod gitpod 0 Sep 19 11:33 bin/install_terraform_cli
```

Alternatively, return the octal format permissions
```bash
$ stat --format="%a" ./script-filename
```

Expected console output:
```
664
```

To change the executable bit, this can be done in two ways.

As a logged in user you can change permissions using the [chmod](https://www.linuxtopia.org/online_books/introduction_to_linux/linux_The_chmod_command.html) command.

```bash
$ chmod u+x ./script-filename
```

Example using the octal format.

```bash
$ chmod 764 ./script-filename
```

### File protection

This file would also be protected against accidental overwriting.

Example protecting a file using the octal format. 

```bash
$ chmod 400 ./filename.ext
```

### install_terraform_cli script

Create a new issue in GitHub, create a new feature branch to work on the issue.

Switch to feature branch, and run Gitpod workspace.

Create a new folder and file in the Gitpod workspace.

```bash
cd /workspace/terraform-beginner-bootcamp-2023-azure
mkdir bin && touch ./bin/install_terraform_cli
```

Open the file for editing and add the shebang to the first line of the new file.

```bash
#!/usr/bin/env bash
```

Copy and paste into the new file the Ubuntu/Debian installation commands from the [Terraform documentation](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform).

Run the script manually and test the Terraform CLI was installed.

Set executable permission.

```bash
$ chmod 764 ./bin/install_terraform_cli
```
Run the script.
```bash
$ ./bin/install_terraform_cli
```

Test the installation.

```bash
$ terraform -version
```

Example console output:
```
Terraform v1.5.7
on linux_amd6
```

### Refactor the .gitpod.yml file for install_terraform_cli

Remove the four lines of bash commands installing terraform from the init task.

Rename init task to before task. 
```yml
before: |
```

Add a new line.
```yml
before: |
      source ./bin/install_terraform_cli
```
This command will execute the install_terraform_cli bash script.

### Refactor Terraform installation script

Bash scripts that may download files or update system packages are best not executed in the project root folder, as some stray files may accidentally make it into version control. 

To avoid this we should change the working folder to a folder outside of version control either before running the script or during.

Upon script completion we should then change back to the project root folder.

We can define the project root folder as an environmental variable. We can then use this variable inside our script.


### Environmental variables

An environmental variable[<sup>[1]</sup>](#external-references) is a user-definable value that can be used by a process or multiple processes. They allow common values to span multiple processes. Hard coding values into code is not recommended, so defining
environmental variables outside of code is best practice. This is particularly important with secret credentials.

Environmental variables can be set temporarily or permanently.

It is conventional for environment-variable names to be in all upper case. In programming code generally, this helps to distinguish environment variables from other kinds of names in the code. Environment-variable names are case sensitive on Unix-like operating systems but not on DOS, OS/2, and Windows.

Example:

```bash
PROJECT_ROOT='/workspace/terraform-beginner-bootcamp-2023-azure'
```

The variables can be used both in scripts and on the command line. They are usually referenced by putting special symbols in front of or around the variable name.

```bash
cd $PROJECT_ROOT
```

In most Unix and Unix-like command-line shells, an environment variable's value is retrieved by placing a $ sign before the variable's name. If necessary, the name can also be surrounded by braces.


```bash
echo ${PROJECT_ROOT}
```

Searching for set environmental variables is best done by using the env command along side the grep command.

```bash
env | grep PROJECT_ROOT
```

A variable can be cleared or unset by using the unset command.

```bash
unset PROJECT_ROOT
```

To persist an environmental variable across restarts or new shells, the variable needs to be defined in a special file or location.

Depending on your Linux OS, this file may be .bashrc or .profile or perhaps use both, refer to the documentation for your operating system. 

If environmental variables are used, it is best practice to create a file called .env.example
and place the actual variable name with fake values inside this file. Other developers will then know they may need to update or set
the variable value according to there environment or security credentials.

### Gitpod environmental variables

Gitpod supports encrypted, user-specific environment variables[<sup>[2]</sup>](#external-references). They are stored as part of your user settings and can be used to set access tokens, or pass any other kind of user-specific information to your workspaces.

Setting user-specific environment variables

Using the command: gp env

```bash
gp env PROJECT_ROOT='/workspace/terraform-beginner-bootcamp-2023-azure'
```

Beware that this does not modify your current terminal session, but rather persists this variable for the next workspace on this repository. gp can only interact with the persistent environment variables for this repository, not the environment variables of your terminal. If you want to set that environment variable in your terminal, you can do so using -e:

The gp CLI prints and modifies the persistent environment variables associated with your user for the current repository.

### Terraform CLI fundamentals

We use the Terraform Command Line Interface (CLI) to manage infrastructure, and interact with Terraform state, providers, configuration files, and Terraform Cloud.

The core Terraform workflow[<sup>[3]</sup>](#external-references) consists of three main steps after you have written your Terraform configuration:

- Initialize prepares the working directory so Terraform can run the configuration.
- Plan enables you to preview any changes before you apply them.
- Apply makes the changes defined by your Terraform configuration to create, update, or destroy resources.

### Cloud provider resource names

When creating resources in the cloud, you mostly always need to provide a unique name that complies with the cloud providers naming convention for that resource. Hard coding a unique name is not advisable. It is best to use a tool to create a random name. In Terraform we can use [Random Provider - random_string](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) to do this. Always check the naming rules with the cloud providers documentation. Terraform cannot check naming rules or names availability.

### A simple main.tf example

This main.tf file uses the Hashicorp Random Provider, to generate a unique 24 character lower case string. This string will comply with the [Storage account name](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview#storage-account-name) for an Azure Storage account. 

We use the "random_string" resource to generate a random 16 character string identified as **name**. 

We define one output "random_bucket_name" that is the .result of the "random_string" resource.

main.tf
```hcl
terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

provider "random" {
  # Configuration options
}

resource "random_string" "storage_account_name" {
  length = 24
  special = false
  upper = false
}

output "random_storage_account_name" {
  value = random_string.storage_account_name.result
}
```

### Terraform basic usage example
- Create a file with the name main.tf
- Paste the contents of the example above into the file.
- Open a terminal prompt in the same folder as main.tf then type.

```bash
$ terraform init
```
Initialize prepares the working directory so Terraform can run the configuration. 

A new folder is created.

- .terraform

This folder is used to store the project's providers and modules. Terraform will refer to these components when you run validate, plan, and apply,

One new file is created:-

- .terraform.lock.hcl 

The .terraform.lock.hcl file ensures that Terraform uses the same provider versions across your team and in ephemeral remote execution environments. During initialization, Terraform will download the provider versions specified by this file rather than the latest versions. This file should be under version control.

Now run the following command.

```bash
$ terraform plan
```

Plan enables you to preview any changes before you apply them. The command can be omitted, as command 'terraform apply' does a new plan as part of its process.

If everything looks good then run the following command. 

```bash
$ terraform apply --auto-approve
```

Apply makes the changes defined by your Terraform configuration to create, update, or destroy resources. The use of **--auto-approve** removes the need for you to type 'yes' when prompted.

One new file is created:-

- terraform.tfstate 

This State File contains full details of resources in our terraform code. When you modify something on your code and apply it on cloud, terraform will look into the state file, and compare the changes made in the code from that state file and the changes to the infrastructure based on the state file.[<sup>[6]</sup>](#external-references)  


In the console there should be the output displaying the
'random_bucket_name'. 

```bash
Outputs:

random_storage_account_name = "1ri2e8o13vorgt72gukhx4em"
```

Now the resources have been applied, we can retrieve the value of the 'random_bucket_name' by using the following command.

```bash
$ terraform output random_storage_account_name
```

Expected console output.
```bash
"1ri2e8o13vorgt72gukhx4em"
```

You can use Terraform outputs to connect your Terraform projects with other parts of your infrastructure, or with other Terraform projects.[<sup>[13]</sup>](#external-references)

### Terraform files and version control
Your .gitignore file must contain exclusions for many of the generated Terraform folders and files. The only files needed to be under version control[<sup>[4]</sup>](#external-references) are:

```bash
main.tf
.terraform.lock.hcl
```

- [Example .gitignore for Terraform](https://github.com/github/gitignore/blob/main/Terraform.gitignore)


## Azure CLI

The Azure Command-Line Interface (CLI) is a cross-platform command-line tool to connect to Azure and execute administrative commands on Azure resources. It allows the execution of commands through a terminal using interactive command-line prompts or a script.[<sup>[5]</sup>](#external-references)

### Installation of Azure CLI in Gitpod workspace

The commands used to install the Azure CLI for Linux are described [here](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt#option-2-step-by-step-installation-instructions).

As there are multiple command lines needed to install Azure CLI, we shall not clutter the .gitpod.yml with these commands, but shall create a bash script.


### install_azure_cli script

Create a new issue in GitHub, create a new feature branch to work on the issue.

Switch to feature branch, and run Gitpod workspace.

Create a new folder and file in the Gitpod workspace.

```bash
$ cd /workspace/terraform-beginner-bootcamp-2023-azure
$ mkdir bin && touch ./bin/install_azure_cli
```

Open the file for editing and add the shebang to the first line of the new file.

```bash
#!/usr/bin/env bash
```

Copy and paste into the new file the Ubuntu/Debian installation commands from the [Install the Azure CLI on Linux](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt#option-2-step-by-step-installation-instructions).

Run the script manually and test the Terraform CLI was installed.

Set executable permission.

```bash
chmod 764 ./bin/install_azure_cli
```
Run the script.
```bash
./bin/install_azure_cli
```

Test the installation.

```bash
az version
```

Example console output:
```sh
{
  "azure-cli": "2.53.0",
  "azure-cli-core": "2.53.0",
  "azure-cli-telemetry": "1.1.0",
  "extensions": {}
}
```

### Refactor the .gitpod.yml file for install_azure_cli

We now have two scripts, which both use the apt package manager to install packages. If both scripts start at the same time one script will not complete due to apt creating a lock file which prevents other processes from using apt at the same time.

To get around this we can use Gitpod features [gp sync-done](https://www.gitpod.io/docs/references/gitpod-cli#sync-done) and [gp sync-await](https://www.gitpod.io/docs/references/gitpod-cli#sync-await)


```yml
tasks:
  - name: terraform-cli
    env:
      TF_LOG: DEBUG
    before: |
      cd $PROJECT_ROOT
      source ./bin/create_bash_aliases
      source ./bin/install_terraform_cli
      gp sync-done terraform-cli
  - name: azure-cli
    before: |
      cd $PROJECT_ROOT
      source ./bin/create_bash_aliases
      gp sync-await terraform-cli && source ./bin/install_azure_cli
```

Task, azure-cli will execute the install_azure_cli bash script only when the terraform-cli task has completed. 



## Terraform and Azure

To use Azure with Terraform we need to add Azure to the providers block in the main.tf file. The code needed can be found on the Terraform registry webpage by searching for [Provider Azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs). Click on USE PROVIDER and copy the azurerm specific block, as shown below.

```hcl
azurerm = {
      source = "hashicorp/azurerm"
      version = "3.76.0"
    }
```

**Note:** The main.tf can only have one terraform {} block and one required_providers {} block. Multiple providers are listed in the required_provider{} block, as shown below.

```hcl
terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "3.5.1"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.76.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

### Authentication and Configuration

Terraform supports a number of different methods for [authenticating to Azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure):

- Azure CLI
- Managed Service Identity
- Service Principal and a Client Certificate
- Service Principal and a Client Secret
- OpenID Connect


**Warning:** Hard-coded credentials are not recommended in any Terraform configuration and risks secret leakage should this file ever be committed to a public version control system.

It is recommended to use either a Service Principal or Managed Service Identity when running Terraform non-interactively (such as when running Terraform in a CI server) - and authenticating using the Azure CLI when running Terraform locally.

I have chosen to use a Service Principal and a client Secret for this project.

### Service Principal

Service Principal is an application within Azure Active Directory, which is authorised to access resources in Azure. This access is restricted by the roles assigned to the service principal, giving you control over which resources can be accessed and at which level.[<sup>[6]</sup>](#external-references)

We wil create a Service Principal for developing this application. We need to access resources in our subscription and perform operations on them. The required role to achieve this is called **Contributor**. This role
grants full access to manage all resources, but does not allow you to assign roles in Azure RBAC, manage assignments in Azure Blueprint.

### Creating a Service Principal using the Azure CLI

Launch a Gitpod workspace for the git branch you are working on. 

Enter the Azure CLI terminal.

Login to your Azure subscription using the [az login](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli-interactively) command.

```sh
az login --use-device-code 
```

We need to obtain your subscription id, use the [az account list](https://learn.microsoft.com/en-us/cli/azure/account?view=azure-cli-latest#az-account-list()) command.

```sh
az account list
```

Using the subscription id, we can create a Service Principal. Using the [az ad sp create-for-rbac](https://learn.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest#az-ad-sp-create-for-rbac) command.

```sh
az ad sp create-for-rbac -n Gitpod --role Contributor
 --scopes /subscriptions/EXAMPLE3-464a-4687-a03a-82efdEXAMPLE
```

#### Example console output
```sh
$ Creating 'Contributor' role assignment under scope '/subscriptions/EXAMPLE3-464a-4687-a03a-82efdEXAMPLE'
The output includes credentials that you must protect. Be sure that you do not include these credentials in your code or check the credentials into your source control. For more information, see https://aka.ms/azadsp-cli
{
  "appId": "EXAMPLE3-464a-4687-a03a-82efdEXAMPLE",
  "displayName": "Gitpod",
  "password": "EXAMPLEbn2ljUNipS.g3WXfA9x2ccqy25EXAMPLE",
  "tenant": "EXAMPLEb-8906-45b6-bf08-b29d9EXAMPLE"
}
```

These values map to the Terraform Azure provider variables like so:

- appId is the ARM_CLIENT_ID
- password is the ARM_CLIENT_SECRET
- tenant is the ARM_TENANT_ID

### Adding Service Principal credentials to Gitpod workspace

We need to create four environmental variables to use the Service Principal with the Terraform Azure provider.

#### Example variables

```bash
ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
ARM_CLIENT_SECRET="12345678-0000-0000-0000-000000000000"
ARM_TENANT_ID="10000000-0000-0000-0000-000000000000"
ARM_SUBSCRIPTION_ID="20000000-0000-0000-0000-000000000000"
```

**Important:**
We should always surround our environmental variable values with single or double quotes. This prevents [bash interpreter interpolation](https://www.baeldung.com/linux/bash-escape-characters).


As detailed in section Gitpod environmental variables. We can assign persistent environment variables to the Gitpod workspace using

```bash
gp env ENVVAR_NAME="envvar-value"
```
Therefore, we should enter the following in the Gitpod workspace terminal window. Substituting the fake values with the real values.

```bash
gp env ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
gp env ARM_CLIENT_SECRET="12345678-0000-0000-0000-000000000000"
gp env ARM_TENANT_ID="10000000-0000-0000-0000-000000000000"
gp env ARM_SUBSCRIPTION_ID="20000000-0000-0000-0000-000000000000"
```

These variables will only take effect on the creation of a new Gitpod workspace. To test them, first stop the current workspace and open a new workspace. Then open a workspace terminal and type:

```bash
env | grep ARM_
```

### Test the Service Principal credentials

We can test our Service Principal credentials by logging in with them using the Azure CLI command shown below.

```bash
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
```

#### Example console output
```bash
[
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "10000000-0000-0000-0000-000000000000",
    "id": "20000000-0000-0000-0000-000000000000",
    "isDefault": true,
    "managedByTenants": [],
    "name": "Azure subscription 1",
    "state": "Enabled",
    "tenantId": "10000000-0000-0000-0000-000000000000",
    "user": {
      "name": "EXAMPLE3-464a-4687-a03a-82efdEXAMPLE",
      "type": "servicePrincipal"
    }
  }
]
```


## Azure storage account

An [Azure storage account](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview) contains all of your Azure Storage data objects: blobs, files, queues, and tables. The storage account provides a unique namespace for your Azure Storage data that's accessible from anywhere in the world over HTTP or HTTPS. Data in your storage account is durable and highly available, secure, and massively scalable.

Azure Storage offers several types of storage accounts. Each type supports different features and has its own pricing model.

- Standard general purpose v2
this is standard storage for blob, file shares, queues and tables

- Premium block blobs
this is supported for block and append blobs, this is when you
want fast access to your blobs and high transaction rates

- Premium page blobs
for storing virtual hard disk vhd for you virtual machines
when you want fast access to your blobs, high transaction rates

- Premium file shares
this is supported for file shares. this is when you want fast access
to your files, high transaction rates

For this project I will use Standard general purpose v2.

### Creating a storage account
A storage account is an Azure Resource Manager resource. Resource Manager is the deployment and management service for Azure. For more information, see [Azure Resource Manager overview](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/overview).

Every Resource Manager resource, including an Azure storage account, must belong to an Azure resource group. A resource group is a logical container for grouping your Azure services. When you create a storage account, you have the option to either create a new resource group, or use an existing resource group. This how-to shows how to create a new resource group.

### Creating a resource group with Terraform

Firstly we must create a [resource group](https://learn.microsoft.com/en-gb/azure/azure-resource-manager/management/overview#resource-groups) for our project. All resources provisioned for this project shall be contained in this resource group.

To create a resource group with Terraform we refer to the Terraform Azure provider documentation for resource groups[<sup>[7]</sup>](#external-references).

We copy the code block detailed in the documentation and update the values accordingly.

```hcl
# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "terraform-beginner-bootcamp-2023-azure"
  location = "UK South"
}
```

### Creating a general-purpose v2 storage account with Terraform

To create a general-purpose v2 storage account with Terraform we refer to the Terraform Azure provider documentation for Azure Storage Account [<sup>[8]</sup>](#external-references).

We copy the code block detailed in the documentation and update the values accordingly.


```hcl
# Create a storage account
resource "azurerm_storage_account" "st" {
  name = "terraformaccount20231017105432"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_tier = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"

  static_website {
    index_document = "index.html"

  }
}
```

name - (Required) Specifies the name of the storage account. Only lowercase Alphanumeric characters allowed. Changing this forces a new resource to be created. This must be unique across the entire Azure service, not just within the resource group

To save typing the name of the resource group for every new resource
created. I have used the .name suffix after azurerm_resource_group.rg.

To save typing the location for every new resource created. I have used the .location suffix after azurerm_resource_group.rg

To allow the storage account to store a static website I have
enabled it, by passing the following:-

```hcl
  static_website {
    index_document = "index.html"

  }
```

### Creating blob storage with Terraform

As we are using the storage account to host a static website we must also create blob storage to store the websites pages and assets.

To create blob storage with Terraform we refer to the Terraform Azure provider documentation for blob storage [<sup>[9]</sup>](#external-references).

We copy the code block detailed in the documentation and update the values accordingly.

```hcl
# Add a index.html file
resource "azurerm_storage_blob" "blob" {
  name = "index.html"
  storage_account_name = azurerm_storage_account.st.name
  storage_container_name = "$web"
  type = "Block"
  content_type = "text/html"
  source_content = "<h1>Hello, this is a website deployed using Azure storage account and Terraform.</h1>"
}
```

### Testing Terraform configuration

- Update the main.tf accordingly.
- Open a terminal prompt in the same folder as main.tf then type.

```bash
$ terraform init
```
Initialize prepares the working directory so Terraform can run the configuration. Downloads to .terraform folder the Azure provider binary.

```bash
$ terraform plan
```

Plan enables you to preview any changes before you apply them. If everything looks good then run the following command.

```bash
$ terraform apply --auto-approve
```

### Check infrastructure
Login to Azure CLI using:

```bash
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

```

Check that the storage account was created.

```bash
az storage account show -g terraform-beginner-bootcamp-2023-azure -n terraformaccount202310
```

Retrieve the primary endpoint of the storage accounts static website, using command:

```bash
az storage account show -g terraform-beginner-bootcamp-2023-azure -n terraformaccount202310 --query "primaryEndpoints.web"
```

#### Example output
```bash
"https://terraformaccount202310.z33.web.core.windows.net/"
```

Copy the primary endpoint and paste into a new browser tab. You should see the contents of the index.html file.

### Destroy infrastructure
Now delete the Azure resources using terraform destroy. This command terminates resources managed by your Terraform project. This command is the inverse of terraform apply in that it terminates all the resources specified in your Terraform state. It does not destroy resources running elsewhere that are not managed by the current Terraform project.

```bash
$ terraform destroy --auto-approve
```

The file below is updated:-

- terraform.tfstate 

This State File contains full details of resources in our terraform code. When you modify something on your code and apply it on cloud, terraform will look into the state file, and compare the changes made in the code from that state file and the changes to the infrastructure based on the state file.[<sup>[10]</sup>](#external-references)

Using Azure CLI check that the storage account no longer exists:

```bash
az storage account show -g terraform-beginner-bootcamp-2023-azure -n terraformaccount202310
```

#### Expected output
```bash
(ResourceGroupNotFound) Resource group 'terraform-beginner-bootcamp-2023-azure' could not be found.
Code: ResourceGroupNotFound
Message: Resource group 'terraform-beginner-bootcamp-2023-azure' could not be found.
```

## Terraform Cloud

As mentioned the terraform.tfstate file is very important. It's important to protect your state file. If you lose the state file, Terraform will have no way to know what it built or what could be safe to delete or change.

The default setting of Terraform is to store your state file on your local laptop or your workstation. This works great for a single developer or someone working alone on a project, but as soon as you have 2 or more people trying to work on the same project, this can become a problem.

We will use a "remote state." This is a centrally stored state file where multiple uses can access the state of your infrastructure. Remote state can be stored either on cloud platform storage, like S3, or inside of Terraform Cloud.

Terraform Cloud provides all of the features we need to work with remote state, including locking, collaboration, and encryption.

### Terraform Cloud pricing

In the Free tier we get 500 resources per month, and do not need to provide a credit card. If we exceed 500 resources per month we will switch to the Standard tier. The Standard tier requires a credit card to be registered.[<sup>[11]</sup>](#external-references)

### Register for a new Terraform Cloud account
Go to webpage [terraform.io](https://www.terraform.io/)

- Click on Try Terraform Cloud
- Register a new account
- Follow all the prompts, then you are ready to use Terraform Cloud.

### Configure Terraform Cloud
Go to [Terraform Cloud login](https://app.terraform.io/session)
- Login to your Terraform Cloud account.
- Create a new [organization](https://app.terraform.io/app/organizations/new).
- Create a new [Project](https://app.terraform.io/app/mpflynnx/workspaces). Click on New and select Project from dropdown. Give a project name as 'terraform-beginner-bootcamp-azure'. Click Create button.
- Create a new CLI-driven workflow [workspace](https://app.terraform.io/app/mpflynnx/workspaces/new).
- Give Workspace Name as terra-home-1. The name of your workspace is unique and used in tools, routing, and UI. Dashes, underscores, and alphanumeric characters are permitted. Learn more about [naming workspaces](https://www.terraform.io/docs/cloud/workspaces/naming.html)

- Select Project 'terraform-beginner-bootcamp-azure'. Give description. of workspace. The click Create workspace.
- Open a Gitpod workspace for the project.

- Copy the 'Example code' block for cloud then paste this into the main.tf file.

```hcl
terraform {
  cloud {
    organization = "mpflynnx"

    workspaces {
      name = "terra-home-1"
    }
  }
}
```

### Create an API Token

- Log in to Terraform Cloud and go on to [User Settings](https://app.terraform.io/app/settings/profile).

- Click on [Tokens](https://app.terraform.io/app/settings/tokens).

- Click on Create an API token. Give a description as 'TerraTownsAzure'. Set Expiration to 30 days. Click Generate Token.

- Copy the Token now, as you will not be able to see it again, if you close the [Tokens](https://app.terraform.io/app/settings/tokens) browser tab.

- Create new persistent Gitpod environmental variable, substituting the real value, in the command below.

```bash
$ gp env TERRAFORM_CLOUD_TOKEN='EXAMPLERF6rtdg.atlasv1.i1AOIJy0RpyyAsdArLTbZ77ImBFV3Fg8ezGxseOwvAcCcRZzQKiJuJErsrZoEXAMPLE'
```

To save starting a gitpod workspace just to add a new variable. Open a browser tab at [Gitpod variables](https://gitpod.io/user/variables) and add the new variable with Scope 'example_repo_name/terraform-beginner-bootcamp-2023-azure'. 

- Stop and then start the Gitpod workspace for the new environment variable to be available for use.
- Run command below and verify that the TERRAFORM_CLOUD_TOKEN is set.
```bash
$ env | grep TERRAFORM_
```

- Update the .env.example file with a example token as shown above.

### Gitpod problems with Terraform login command

The command ['Terraform login'](https://developer.hashicorp.com/terraform/cli/commands/login), wants to request an API token for app.terraform.io using your internet browser. We are using Gitpod workspace for this project so this will not work. We must come up with another solution for this.

By default, Terraform will obtain an API token and save it in plain text in a local CLI configuration file called credentials.tfrc.json. 

The location of our file is:
```bash
$ /home/gitpod/.terraform.d/credentials.tfrc.json
```

The structure of this file is:
```json
{
  "credentials": {
    "app.terraform.io": {
      "token": "$TERRAFORM_CLOUD_TOKEN"
    }
  }
}
```
### generate_tfrc_credentials bash script

As we are using Gitpod, we need a way of creating the credentials.tfrc.json file on the creation of every new Gitpod workspace. To do this we shall write a bash script. The bash script shall do the following:
- Create a new folder, '.terraform.d', if it doesn't exist
- Create a new file, 'credentials.tfrc.json', if it doesn't exist.
- Use the cat command to build the json block, obtaining the persistent Gitpod environmental variable $TERRAFORM_CLOUD_TOKEN from the local environment.

The script will be placed in the bin folder.

The gitpod.yml file needs to be updated to run this script on the creation of a new Gitpod workspace.

- Run command below and verify that the TERRAFORM_CLOUD_TOKEN is set.
```bash
$ env | grep TERRAFORM_
```

- Make the bash script generate_tfrc_credentials executable with the command below:
```bash
$ cd /workspace/terraform-beginner-bootcamp-2023-azure 
$ chmod u+x ./bin/generate_tfrc_credentials
```
- Run the script, using the command below.
```bash
$ cd /workspace/terraform-beginner-bootcamp-2023-azure
$ ./bin/generate_tfrc_credentials
```
- Check the file exists and contains the TERRAFORM_CLOUD_TOKEN.
```
$ cat /home/gitpod/.terraform.d/credentials.tfrc.json
```
- Run the following command, to test the credentials.

```bash
$ terraform init
```
- You should be presented with the following screen.
```bash
Initializing Terraform Cloud...

Terraform Cloud has been successfully initialized!

You may now begin working with Terraform Cloud. Try running "terraform plan" to
see any changes that are required for your infrastructure.

If you ever set or change modules or Terraform Settings, run "terraform init"
again to reinitialize your working directory.
```

### Terraform Cloud Workspace variables
Terraform Cloud by default uses remote execution mode. Remote mode runs on disposable Linux worker VMs using a POSIX-compatible shell. Before running Terraform operations, Terraform Cloud uses the export command to populate the shell with environment variables. These environment variables can store our Service Principal credentials.

Terraform Cloud lets you define input and environment variables using either workspace-specific variables, or sets of variables that you can reuse in multiple workspaces. [Variable sets](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-create-variable-set) allow you to avoid redefining the same variables across workspaces, so you can standardize common configurations. 

For this project we will define our Service Principal credentials as [workspace-specific variables](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/variables). 

**Precedence**[<sup>[12]</sup>](#external-references)

The credentials will apply only to the to a single 'terra-home-1' workspace. Workspace-specific variables always overwrite variables from variable sets that have the same key. [Refer to overwrite variables from variable sets](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/variables/managing-variables#overwrite-variable-sets) for details.

### Adding Workspace-specific Variables

1. Open a browser tab and login to your [Terraform cloud account](https://app.terraform.io/session).
1. Go to workplace 'terra-home-1'.
1. Click Variables on left hand pane.
1. Scroll down to Workspace variables.
1. Open another browser tab and login to your [Gitpod account](https://gitpod.io/login/).
1. Go to Gitpod, User settings, then click [Variables](https://gitpod.io/user/variables). Here are the Azure credentials we added to our Gitpod account previously. We will copy them for here to the Terraform Cloud workspace.
1. Go back onto the Terraform Cloud 'terra-home-1' workspace browser tab.
1. Click + Add variable.
1. Choose the variable category as environment.
1. Create a new variable with key ARM_CLIENT_ID, copy the value from the Gitpod user settings browser tab.
1. Mark the variable as sensitive. This prevents Terraform from displaying it in the Terraform Cloud UI and makes the variable write-only.
1. Click Add variable.
1. Repeat steps 8 to 12 for the remaining three ARM_ variables.
1. We have now added our Service Principal credentials to the 'terra-home-1' workspace.
1. Check that all variables have Category of 'env' and thr value is marked as 'Sensitive - write only'.

### Terraform Cloud setup confirmation
If you have previously stopped a Gitpod workspace, then open a new Gitpod workspace from the Github project main branch.

```bash
$ terraform init
$ terraform plan
$ terraform apply --auto-approve
```

1. Run the commands above in the order given. These command will login to Terraform Cloud, create a plan, and apply the plan. The terraform.tfstate file will be stored on our Terraform cloud account and not locally.
1. Go on to the Terraform Cloud browser tab and navigate to Workspace 'terra-home-1'.
1. Click on Runs, to see the completed current run.

We have now completed our setup of Terraform Cloud. From here onwards our Azure infrastructure state we be securely stored. Subsequent runs will be logged in Terraform cloud for viewing.

## Terraform cli convenience bash alias

To aid productivity using the terminal we can create aliases to common linux commands. The most popular aliases are for the list 'ls' command. Typing 'ls' on it's own isn't so bad, but the default result isn't particularly helpful. That is why by default many Linux OS's provide aliases for the 'ls' command. These aliases are stored in a '.bashrc' file for the logged in user. 

Here is an example of an alias.
```bash
alias ll='ls -alF'
```

On Ubuntu you can create your own file '.bash_aliases' this will take precedence over .bashrc. We can put our personal bash aliases in this file. For example you may want to have an alias for the terraform command below. 
```bash
$ terraform init
```
We can create an alias, so that the same command becomes.

```bash
$ tf init
```
The terraform alias would be:
```bash
alias tf='terraform'
```


For Gitpod, to make this alias persist on the creation of new workspaces, we need to create a bash script that will create the '.bash_aliases' file and populate it with the alias for the terraform command.

The bash script should do the following:-
- Create file /home/gitpod/.bash_aliases, if it doesn't exist.
- Use the cat command to populate the file with the alias.
- Make the aliases available immediately, by using the source command on the .bash_aliases file.
- The bash script should be stored in the '/workspace/terraform-beginner-bootcamp-2023-azure/bin' folder.
- We can make the script executable using the command below:
```bash
$ chmod 764 ./bin/create_bash_aliases
```

The bash script should be run first as part of the .gitpod.yml 'before' task using the source command.

## External References
- [Wikipedia Environment variables](https://en.wikipedia.org/wiki/Environment_variable#Unix) <sup>[1]</sup>

- [Gitpod Environment Variables](https://www.gitpod.io/docs/configure/projects/environment-variables#using-the-account-settings) <sup>[2]</sup>

- [Terraform tutorials - Use the Command Line Interface](https://developer.hashicorp.com/terraform/tutorials/cli) <sup>[3]</sup>

- [How to Create & Use Gitignore File With Terraform](https://spacelift.io/blog/terraform-gitignore)<sup>[4]</sup>

- [What is the Azure CLI?](https://learn.microsoft.com/en-gb/cli/azure/what-is-azure-cli?view=azure-cli-latest) <sup>[5]</sup>

- [What is Service Principal](https://docs.serverless360.com/docs/what-is-service-principal)<sup>[6]</sup>

- [Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)<sup>[7]</sup>

- [azurerm_storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)<sup>[8]</sup>

- [azurerm_storage_blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob)<sup>[9]</sup>

- [What Is Terraform State File And How It Is Managed?](https://www.easydeploy.io/blog/terraform-state-file/)<sup>[10]</sup>

- [Terraform Cloud Free and Paid Plans](https://developer.hashicorp.com/terraform/cloud-docs/overview#free-and-paid-plans)<sup>[11]</sup>

- [Terraform Cloud Variable Precedence](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/variables#precedence)<sup>[12]</sup>

- [Output data from Terraform](https://developer.hashicorp.com/terraform/tutorials/configuration-language/outputs)<sup>[13]</sup>

- [Abbreviation examples for Azure resources](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)