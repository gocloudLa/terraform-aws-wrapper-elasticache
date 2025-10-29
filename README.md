# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform ElastiCache Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-wrapper-elasticache/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-wrapper-elasticache.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-wrapper-elasticache.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-elasticache/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
The Terraform Wrapper for ElastiCache simplifies the creation of Amazon's ElastiCache service (Redis compatibility), creates clusters, redistributes DNS, and associates the SecurityGroup with the service.

### ✨ Features

- 📦 [Log Delivery Configuration](#log-delivery-configuration) - Create Cloudwatch LogGroup and configure slow-log / engine-log in Elasticache

- 👥 [User Management](#user-management) - Manage the creation of users and their ACLs

- 🌐 [DNS Records](#dns-records) - Register a CNAME DNS record in a Route53 hosted zone that is present within the account.

- 🚨 [Alarms Configuration](#alarms-configuration) - Enables and customizes CloudWatch alarms for the elasticache.



### 🔗 External Modules
| Name | Version |
|------|------:|
| <a href="https://github.com/terraform-aws-modules/terraform-aws-elasticache" target="_blank">terraform-aws-modules/elasticache/aws</a> | 1.7.0 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-security-group" target="_blank">terraform-aws-modules/security-group/aws</a> | 5.3.0 |



## 🚀 Quick Start
```hcl
elasticache_parameters = {
  "ExSimple" = {
    subnets = data.aws_subnets.database.ids

    # engine_version         = "7.1"
    # parameter_group_family = "redis7"
    # node_type              = "cache.t4g.micro"

    dns_records = {
      "" = {
        zone_name    = local.zone_private
        private_zone = true
      }
    }
  }

  "ExCluster" = {
    subnets = data.aws_subnets.database.ids

    # Clustered mode
    cluster_mode_enabled       = true
    cluster_mode               = "enabled"
    num_node_groups            = 2
    replicas_per_node_group    = 3
    automatic_failover_enabled = true
    multi_az_enabled           = true

    dns_records = {
      "" = {
        zone_name    = local.zone_private
        private_zone = true
      }
    }
  }
}
elasticache_defaults = var.elasticache_defaults
```


## 🔧 Additional Features Usage

### Log Delivery Configuration
Create Cloudwatch LogGroup and configure slow-log / engine-log in Elasticache


<details><summary>Configuration Code</summary>

```hcl
log_delivery_configuration = {
  engine-log = {
    # cloudwatch_log_group_name = "" # Default: {common_name}-{each.key} / dmc-prd-example-00
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    # cloudwatch_log_group_retention_in_days = 30 # Default: 14
  }
  slow-log = {
    # Conflicts if not defined and both log-groups are enabled
    # https://github.com/terraform-aws-modules/terraform-aws-elasticache/issues/16
    cloudwatch_log_group_name = "dmc-prd-example-00-slow" # Default: {common_name}-{each.key} / dmc-prd-example-00
    destination_type          = "cloudwatch-logs"
    log_format                = "json" 
  }
}
```


</details>


### User Management
Manage the creation of users and their ACLs


<details><summary>Configuration Code</summary>

```hcl
user_group = {
  # create_default_user = true
  default_user = {
    # CONNECTION MODE: redis-cli -h ${HOST} -p 6379 --tls --pass password_default_user_1234567890
    # IMPORTANT!! Users are at account level, therefore names must be UNIQUE!!
    user_id   = "dmc-prd-example-exusers-default"
    passwords = ["password_default_user_1234567890"]
    # access_string = "" # Default: "on ~* +@all" (administrator)
  }
  users = {
    "dmc-prd-example-exusers-administrator" = {
      # CONNECTION MODE: redis-cli -h ${HOST} -p 6379 --tls --user dmc-prd-example-useexusersrs-administrator --pass password_administrator_1234567890
      passwords     = ["password_administrator_1234567890"]
      access_string = "on ~* +@all"
    }
    "dmc-prd-example-exusers-readonly" = {
      # CONNECTION MODE: redis-cli -h ${HOST} -p 6379 --tls --user dmc-prd-example-exusers-readonly --pass password_readonly_1234567890
      passwords     = ["password_readonly_1234567890"]
      access_string = "on ~* -@all +@read"
    }
  }
}
```


</details>


### DNS Records
Register a CNAME DNS record in a Route53 hosted zone that is present within the account.


<details><summary>Configuration Code</summary>

```hcl
dns_records = {
  "" = {
    zone_name    = local.zone_private
    private_zone = true
  }
}
```


</details>


### Alarms Configuration
This configuration block allows enabling, customizing, or disabling CloudWatch alarms. By default, alarms are not created 

You can:
  - Enable alarms globally for the resource (`enable_alarms = true`).
  - Override default alarm parameters using `alarms_overrides`.
  - Disable specific default alarms using `alarms_disabled`.
  - Add completely custom alarms using `alarms_custom`.


<details><summary>Enable default alarms</summary>

```hcl
enable_alarms = true
```


</details>

<details><summary>Override default alarm parameters</summary>

```hcl
alarms_overrides = {
  "warning-CPUUtilization" = {
    "actions_enabled"     = true
    "evaluation_periods"  = 2
    "datapoints_to_alarm" = 2
    "threshold"           = 30
    "period"              = 180
    "treat_missing_data"  = "ignore"
  }
}
```


</details>

<details><summary>Disable specific alarms</summary>

```hcl
alarms_disabled = ["critical-CPUUtilization", "critical-EBSByteBalance", "critical-EBSIOBalance"]
```


</details>

<details><summary>Add custom alarms</summary>

```hcl
alarms_custom = {
  "warning-FreeableMemory" = {
    # This alarm helps to monitor low freeable memory which can mean that there is a spike in database connections or that your instance may be under high memory pressure.
    description         = "FreeableMemory below 350 MB"
    threshold           = 367001600
    unit                = "Bytes"
    metric_name         = "FreeableMemory"
    statistic           = "Average"
    namespace           = "AWS/ElastiCache"
    period              = 60
    evaluation_periods  = 15
    datapoints_to_alarm = 15
    comparison_operator = "LessThanThreshold"
    alarms_tags = {
      "alarm-level" = "WARN"
      }
    }
  "critical-FreeableMemory" = {
    description = "FreeableMemory below 250 MB"
    # This alarm helps to monitor low freeable memory which can mean that there is a spike in database connections or that your instance may be under high memory pressure.
    threshold           = 262144000
    unit                = "Bytes"
    metric_name         = "FreeableMemory"
    statistic           = "Average"
    namespace           = "AWS/ElastiCache"
    period              = 60
    evaluation_periods  = 15
    datapoints_to_alarm = 15
    comparison_operator = "LessThanThreshold"
    alarms_tags = {
      "alarm-level" = "CRIT"
      }
    }
}
```


</details>




## 📑 Inputs
| Name                                 | Description                                                                                                                         | Type     | Default                                                           | Required |
| ------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------- | -------- | ----------------------------------------------------------------- | -------- |
| elasticache_parameters               | Map containing parameters for the configuration of ElastiCache clusters.                                                            | `map`    | `{}`                                                              | no       |
| create_enable                        | Enables or disables the creation of the resource.                                                                                   | `bool`   | `true`                                                            | no       |
| name                                 | Name of the ElastiCache resource. Generated by combining `local.common_name` and the key of each entry in `elasticache_parameters`. | `string` | `-`                                                               | no       |
| engine_version                       | ElastiCache engine version to use.                                                                                                  | `string` | `"7.1"`                                                           | no       |
| node_type                            | ElastiCache node type.                                                                                                              | `string` | `"cache.t4g.micro"`                                               | no       |
| parameter_group_family               | Parameter group family for ElastiCache.                                                                                             | `string` | `"redis7"`                                                        | no       |
| port                                 | Port on which the ElastiCache service runs.                                                                                         | `string` | `"6379"`                                                          | no       |
| security_group_ids                   | List of security group IDs associated with ElastiCache.                                                                             | `list`   | `[module.security_group_elasticache[each.key].security_group_id]` | no       |
| subnets                              | List of subnets where ElastiCache will be deployed. If not specified, it will be `null`.                                            | `list`   | `null`                                                            | no       |
| snapshot_retention_limit             | Number of days to retain ElastiCache snapshots.                                                                                     | `number` | `7`                                                               | no       |
| snapshot_window                      | Time window for taking snapshots.                                                                                                   | `string` | `"08:00-09:00"`                                                   | no       |
| maintenance_window                   | Maintenance window for ElastiCache.                                                                                                 | `string` | `"sun:09:30-sun:10:30"`                                           | no       |
| transit_encryption_enabled           | Enables in-transit encryption for ElastiCache.                                                                                      | `bool`   | `false`                                                           | no       |
| auto_minor_version_upgrade           | Enables automatic minor version upgrades for ElastiCache.                                                                           | `bool`   | `true`                                                            | no       |
| apply_immediately                    | Indicates whether changes should be applied immediately.                                                                            | `bool`   | `true`                                                            | no       |
| cluster_mode_enabled                 | Enables cluster mode in ElastiCache.                                                                                                | `bool`   | `false`                                                           | no       |
| cluster_mode                         | Specifies whether cluster mode is enabled or disabled. Valid values are enabled or disabled or compatible.                          | `string` | `null`                                                            | no       |
| cluster_mode_num_node_groups         | Number of node groups in cluster mode.                                                                                              | `number` | `null`                                                            | no       |
| cluster_mode_replicas_per_node_group | Number of replicas per node group in cluster mode.                                                                                  | `number` | `null`                                                            | no       |
| global_replication_group_id_suffix   | Suffix for the global replication group ID of ElastiCache.                                                                          | `string` | `null`                                                            | no       |
| tags                                 | A map of tags to assign to resources.                                                                                               | `map`    | `{}`                                                              | no       |








---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la

## 🧑‍💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details. 