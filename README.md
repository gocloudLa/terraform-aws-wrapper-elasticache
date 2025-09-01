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



### 🔗 External Modules
| Name | Version |
|------|------:|
| [terraform-aws-modules/elasticache/aws](https://github.com/terraform-aws-modules/elasticache-aws) | 1.7.0 |
| [terraform-aws-modules/elasticache/aws](https://github.com/terraform-aws-modules/elasticache-aws) | 1.6.2 |
| [terraform-aws-modules/security-group/aws](https://github.com/terraform-aws-modules/security-group-aws) | 5.3.0 |



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
    # Entra en conflicto si no se define y se habilitan ambos log-groups
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
    # MODO DE CONEXION: redis-cli -h ${HOST} -p 6379 --tls --pass password_default_user_1234567890
    # IMPORTANTE!! Los users son va nivel cuenta, por lo tanto los nombres tiene que ser UNICOS!!
    user_id   = "dmc-prd-example-exusers-default"
    passwords = ["password_default_user_1234567890"]
    # access_string = "" # Default: "on ~* +@all" (administrator)
  }
  users = {
    "dmc-prd-example-exusers-administrator" = {
      # MODO DE CONEXION: redis-cli -h ${HOST} -p 6379 --tls --user dmc-prd-example-useexusersrs-administrator --pass password_administrator_1234567890
      passwords     = ["password_administrator_1234567890"]
      access_string = "on ~* +@all"
    }
    "dmc-prd-example-exusers-readonly" = {
      # MODO DE CONEXION: redis-cli -h ${HOST} -p 6379 --tls --user dmc-prd-example-exusers-readonly --pass password_readonly_1234567890
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











---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la
- 🐛 **Issues**: [GitHub Issues](https://github.com/gocloudLa/issues)

## 🧑‍💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details. 