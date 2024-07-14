resource "aws_dynamodb_table" "basic_table" {
  name                        = var.name
  billing_mode                = var.billing_mode
  hash_key                    = var.hash_key
  range_key                   = var.range_key
  table_class                 = var.table_class
  deletion_protection_enabled = var.deletion_protection_enabled


  ttl {
      enabled        = var.ttl_enabled
      attribute_name = var.ttl_attribute_name
  }

  point_in_time_recovery {
      enabled = var.point_in_time_recovery_enabled
  }

  dynamic "attribute" {
      for_each = var.attributes

      content {
        name = attribute.value.attribute_name
        type = attribute.value.data_type
      }
  }

  dynamic "local_secondary_index" {
      for_each = var.local_secondary_indexes
      content {
        name               = local_secondary_index.value.index_name
        range_key          = local_secondary_index.value.sort_key
        projection_type    = local_secondary_index.value.attribute_projections
      }
  }

  dynamic "global_secondary_index" {
      for_each = var.global_secondary_indexes

      content {
        name               = global_secondary_index.value.name
        hash_key           = global_secondary_index.value.hash_key
        projection_type    = global_secondary_index.value.projection_type
        range_key          = lookup(global_secondary_index.value, "range_key", null)
      }
  }

  server_side_encryption {
    enabled     = var.server_side_encryption_enabled
  }
}
[heracles@dk-az-config-001 sn_csc_dynamo_db]$ ls -al
total 16
drwxr-xr-x  2 heracles heracles   60 Jul 11 17:04 .
drwxrwxr-x 27 heracles heracles 4096 Jul 11 17:04 ..
-rw-r--r--  1 heracles heracles 1506 Jul 11 17:04 main.tf
-rw-r--r--  1 heracles heracles  105 Jul 11 17:04 provider.tf
-rw-r--r--  1 heracles heracles 2932 Jul 11 17:04 variables.tf
[heracles@dk-az-config-001 sn_csc_dynamo_db]$ sudo cat provider.tf 
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}
[heracles@dk-az-config-001 sn_csc_dynamo_db]$ sudo cat variables.tf 
variable "access_key" {}
variable "secret_key" {}

variable "region" {
  default     = "us-west-1"
  description = "AWS region"
}

variable "name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "dynamo-tbl-01"
}

variable "attributes" {
  description = "List of nested attribute definitions. Only required for hash_key and range_key attributes. Each attribute has two properties: name - (Required) The name of the attribute, type - (Required) Attribute type, which must be a scalar type: S, N, or B for (S)tring, (N)umber or (B)inary data"
  type        = list(object({
     attribute_name  = string
     data_type  = string
   }))
}

variable "local_secondary_indexes" {
  description = "Describe an LSI on the table; these can only be allocated at creation so you cannot change this definition after you have created the resource."
  type        =  list(object({
     index_name              = string
     sort_key                = string
     attribute_projections   = string
   }))
}

variable "global_secondary_indexes" {
  description = "Describe a GSI for the table; subject to the normal limits on the number of GSIs, projected attributes, etc."
  type        = list(object({
     name               = string
     hash_key           = string
     range_key          = string
     projection_type    = string
   }))
}

variable "hash_key" {
  description = "The attribute to use as the hash (partition) key. Must also be defined as an attribute"
  type        = string
  default     = "idx_pk_01"
}

variable "range_key" {
  description = "The attribute to use as the range (sort) key. Must also be defined as an attribute"
  type        = string
  default     = "idx_sk_01"
}

variable "billing_mode" {
  description = "Controls how you are billed for read/write throughput and how you manage capacity. The valid values are PROVISIONED or PAY_PER_REQUEST"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "point_in_time_recovery_enabled" {
  description = "Whether to enable point-in-time recovery"
  type        = bool
  default     = true
}

variable "ttl_enabled" {
  description = "Indicates whether TTL is enabled"
  type        = bool
  default     = true
}

variable "ttl_attribute_name" {
  description = "The name of the table attribute to store the TTL timestamp in"
  type        = string
  default     = "TimeToExistEg"
}

variable "server_side_encryption_enabled" {
  description = "Whether or not to enable encryption at rest using an AWS managed KMS customer master key (CMK)"
  type        = bool
  default     = false
}

variable "table_class" {
  description = "The storage class of the table. Valid values are STANDARD and STANDARD_INFREQUENT_ACCESS"
  type        = string
  default     = "STANDARD"
}

variable "deletion_protection_enabled" {
  description = "Enables deletion protection for table"
  type        = bool
  default     = false
}