# VPC module
This module is devlop for join devops. Projects inside the join devops follows this module to create their VPC.

## INPUTS
* projects (required) - user should specify a project name
* Environment (required) - user should specify the environment.
* CIDR_block (optional) - user can provide their CIDR block Default is 10.0.0.0/16

## OUTPUTS
* vpc_id = Exports VPC ID created