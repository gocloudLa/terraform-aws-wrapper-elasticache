module "wrapper_elasticache" {
  source = "../../"

  metadata = local.metadata
  project  = "example"

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

    "ExLegacy" = {
      subnets = data.aws_subnets.database.ids

      # BACKGUARD Compatibility ( module version 1.0 )
      engine_version             = "6.x"
      parameter_group_family     = "redis6.x"
      cluster_mode_enabled       = false
      at_rest_encryption_enabled = false
      transit_encryption_enabled = false
      automatic_failover_enabled = false
      transit_encryption_mode    = null
      # BACKGUARD Compatibility ( module version 1.0 )

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