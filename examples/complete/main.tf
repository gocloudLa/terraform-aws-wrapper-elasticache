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

    "ExAlarms" = {
      subnets = data.aws_subnets.database.ids

      dns_records = {
        "" = {
          zone_name    = local.zone_private
          private_zone = true
        }
      }
      enable_alarms = true # Default: false
      alarms_disabled = [ # if you need to disable an alarm
        "critical-CPUUtilization", 
        "critical-DatabaseMemoryUsagePercentage", 
        "critical-EngineCPUUtilization"
      ]

      # alarms_overrides = {
      #   "warning-CPUUtilization" = {
      #     "actions_enabled"     = true
      #     "evaluation_periods"  = 2
      #     "datapoints_to_alarm" = 2
      #     "threshold"           = 30
      #     "period"              = 180
      #     "treat_missing_data"  = "ignore"
      #   }
      # }

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
        "warning-SwapUsage" = {
          # This alarm helps to monitor the amount of swap used on the host.
          description         = "SwapUsage below 300 MB"
          threshold           = 300000000
          unit                = "Bytes"
          metric_name         = "SwapUsage"
          statistic           = "Average"
          namespace           = "AWS/ElastiCache"
          period              = 60
          evaluation_periods  = 15
          datapoints_to_alarm = 15
          comparison_operator = "GreaterThanThreshold"
          alarms_tags = {
            "alarm-level" = "WARN"
          }
        }
        "critical-SwapUsage" = {
          description = "SwapUsage below 250 MB"
          # This alarm helps to monitor the amount of swap used on the host.
          threshold           = 200000000
          unit                = "Bytes"
          metric_name         = "SwapUsage"
          statistic           = "Average"
          namespace           = "AWS/ElastiCache"
          period              = 60
          evaluation_periods  = 15
          datapoints_to_alarm = 15
          comparison_operator = "GreaterThanThreshold"
          alarms_tags = {
            "alarm-level" = "CRIT"
          }
        }        
        "warning-CurrConnections" = {
          # This alarm is used to detect the number of client connections, excluding connections from read replicas.
          description         = "Triggers if the number of client connections is above the threshold of 30 connections"
          threshold           = 30
          unit                = "Count"
          metric_name         = "CurrConnections"
          statistic           = "Average"
          namespace           = "AWS/ElastiCache"
          period              = 60
          evaluation_periods  = 3
          datapoints_to_alarm = 3
          comparison_operator = "GreaterThanThreshold"
          alarms_tags = {
            "alarm-level" = "WARN"
          }
        }
        "critical-CurrConnections" = {
          # This alarm is used to detect the number of client connections, excluding connections from read replicas.
          description         = "Triggers if the number of client connections is above the threshold of 20 connections"
          threshold           = 20
          unit                = "Count"
          metric_name         = "CurrConnections"
          statistic           = "Average"
          namespace           = "AWS/ElastiCache"
          period              = 60
          evaluation_periods  = 3
          datapoints_to_alarm = 3
          comparison_operator = "GreaterThanThreshold"
          alarms_tags = {
            "alarm-level" = "CRIT"
          }
        }
      }
    }

  }
}