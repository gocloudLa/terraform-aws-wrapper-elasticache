module "wrapper_elasticache" {
  source = "../../"

  metadata = local.metadata

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

    # Allows changing instance size (vertical scaling) with minimal
    # service disruption thanks to Multi-AZ + automatic failover.
    # Docs: https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/AutoFailover.html
    "ExReaderMultiAZ" = {
      subnets = data.aws_subnets.database.ids

      # Single node group with one reader replica distributed across AZs
      cluster_mode_enabled    = false
      num_node_groups         = 1
      replicas_per_node_group = 1
      multi_az_enabled        = true
      #automatic_failover_enabled = true # When multi_az is enabled, this option is automatically enabled

      engine_version         = "7.1"
      parameter_group_family = "redis7"
      node_type              = "cache.t4g.micro"

      dns_records = {
        "" = {
          zone_name    = local.zone_private
          private_zone = true
        }
      }
    }

    "ExUsers" = {
      subnets = data.aws_subnets.database.ids

      dns_records = {
        "" = {
          zone_name    = local.zone_private
          private_zone = true
        }
      }

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
            # MODO DE CONEXION: redis-cli -h ${HOST} -p 6379 --tls --user dmc-prd-example-exusers-administrator --pass password_administrator_1234567890
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
    }

    "ExLogs" = {
      subnets = data.aws_subnets.database.ids

      dns_records = {
        "" = {
          zone_name    = local.zone_private
          private_zone = true
        }
      }
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
    }

  }
}