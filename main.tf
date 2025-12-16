module "elasticache" {
  for_each = var.elasticache_parameters
  source   = "terraform-aws-modules/elasticache/aws"
  version  = "1.10.3"

  cluster_id               = lookup(each.value, "cluster_id", "${local.common_name}-${each.key}")
  create                   = lookup(each.value, "create", true)
  create_cluster           = lookup(each.value, "create_cluster", true)
  create_replication_group = lookup(each.value, "create_replication_group", true)

  replication_group_id = lookup(each.value, "replication_group_id", "${local.common_name}-${each.key}")
  description          = "Elasticache cluster for ${local.common_name}-${each.key}"

  # Clustered mode
  cluster_mode_enabled       = lookup(each.value, "cluster_mode_enabled", false)
  cluster_mode               = lookup(each.value, "cluster_mode", "disabled")
  num_node_groups            = lookup(each.value, "num_node_groups", 1)
  replicas_per_node_group    = lookup(each.value, "replicas_per_node_group", 0)
  automatic_failover_enabled = lookup(each.value, "automatic_failover_enabled", false)
  multi_az_enabled           = lookup(each.value, "multi_az_enabled", false)

  at_rest_encryption_enabled = lookup(each.value, "at_rest_encryption_enabled", true)
  transit_encryption_enabled = lookup(each.value, "transit_encryption_enabled", true)
  transit_encryption_mode    = lookup(each.value, "transit_encryption_mode", "required") # "A setting that enables clients to migrate to in-transit encryption with no downtime. Valid values are preferred and required"

  engine_version = lookup(each.value, "engine_version", "7.1")
  node_type      = lookup(each.value, "node_type", "cache.t4g.micro")

  maintenance_window         = lookup(each.value, "maintenance_window", "sun:09:30-sun:10:30")
  apply_immediately          = lookup(each.value, "apply_immediately", true)
  auto_minor_version_upgrade = lookup(each.value, "auto_minor_version_upgrade", true)

  # # Security Group
  security_group_ids    = [module.security_group_elasticache[each.key].security_group_id]
  create_security_group = false
  # vpc_id = module.vpc.vpc_id
  # security_group_rules = {
  #   ingress_vpc = {
  #     # Default type is `ingress`
  #     # Default port is based on the default engine port
  #     description = "VPC traffic"
  #     cidr_ipv4   = module.vpc.vpc_cidr_block
  #   }
  # }

  # Subnet Group
  subnet_group_name        = lookup(each.value, "subnet_group_name", "${local.common_name}-${each.key}")
  subnet_group_description = "Elasticache subnet group for ${local.common_name}-${each.key}"
  subnet_ids               = lookup(each.value, "subnets", null)

  # Parameter Group
  create_parameter_group      = lookup(each.value, "create_parameter_group", true)
  parameter_group_name        = "${local.common_name}-${each.key}"
  parameter_group_family      = lookup(each.value, "parameter_group_family", "redis7")
  parameter_group_description = "Elasticache parameter group for ${local.common_name}-${each.key}"
  parameters                  = lookup(each.value, "parameters", [])

  log_delivery_configuration = lookup(each.value, "log_delivery_configuration", {})

  port = lookup(each.value, "port", null)


  snapshot_retention_limit = lookup(each.value, "snapshot_retention_limit", "7")
  snapshot_window          = lookup(each.value, "snapshot_window", "08:00-09:00")
  auth_token               = lookup(each.value, "auth_token", null)

  global_replication_group_id_suffix = lookup(each.value, "global_replication_group_id_suffix", null)

  user_group_ids = try(module.elasticache_user_group[each.key].group_id, null) != null ? [module.elasticache_user_group[each.key].group_id] : null

  tags = merge(local.common_tags, try(each.value.tags, var.elasticache_defaults.tags, null))
}


locals {
  # user_group_calculated = {
  #   for elasticache_key, elasticache_config in var.elasticache_parameters :
  #   elasticache_key => {
  #     "user_group" = try(elasticache_config.user_group, {})
  #   } if(try(elasticache_config.user_group, false) != false)
  # }

  user_group_calculated = {
    for elasticache_key, elasticache_config in var.elasticache_parameters :
    elasticache_key => elasticache_config.user_group
    if try(elasticache_config.user_group, false) != false
  }
}

module "elasticache_user_group" {
  for_each = local.user_group_calculated
  source   = "terraform-aws-modules/elasticache/aws//modules/user-group"
  version  = "1.10.3"

  user_group_id = lower("${local.common_name}-${each.key}")
  create        = try(each.value.create, true)

  create_default_user = try(each.value.create_default_user, true)
  # default_user = try(each.value.default_user, {})
  default_user = {
    user_id       = try(lower(each.value.default_user.user_id), lower("${each.key}"))
    access_string = try(each.value.default_user.access_string, "on ~* +@all")
    passwords     = try(each.value.default_user.passwords, [])
  }

  users = try(each.value.users, {})

  tags = local.common_tags
}
