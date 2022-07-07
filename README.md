## Modules

### lambda-infrastructure

To be run once per Environment.  This creates the needed lambda iam role, a lambda developer user, a lambda developer group, a developer key, and one s3 buckets for function code and another for assets.

Individuals added to the lambda development group will be able to use the lambda-developer module.

The module pushes some output to SSM parameter store to be read as Terraform remote state by the lambda-developer module.  Eventually all shared data should be added to SSM and remote state should be abandoned.

### lambda-developer 

A Terraform module to be used in a lambda development project.  The module will allow anyone who is a member of the lambda development group to create a lambda using the module.

## Environments

A folder for should be created for each environment you want to which you want to deploy the lambda infrastructure - dev, staging, etc.  Within the folder utilize the lambda-infrastructure module by putting in variables specific to that enviroment.  When applied the module will create the infrastructure in that environment.  It will prefix the environment name to all created resources.

In order to use remote state, the s3 bucket and dynamoDb table will need to be created before running the the module within an environment folder.  Currently this is done with the files in the 'state' folder under each environment.  This Terraform creates one s3 bucket for remote state to be used for all enviroments.  It creates one dynamoDb table per environment though.  This state configuration may change.

Currently a mapping in the lambda-infrastructure variable file is used to map the 'environment' passed into the module to a region that is then used to create the resources.  This can be improved as it makes assumptions about account usage.



