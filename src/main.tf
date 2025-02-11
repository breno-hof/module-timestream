resource "aws_timestreamwrite_database" "this" {
	count 											= var.should_create_database ? 1 : 0

	database_name									= var.database_name
	kms_key_id										= var.kms_key_arn

	tags											= var.tags
}

resource "aws_timestreamwrite_table" "this" {
	for_each										= var.timestream_tables

	database_name									= var.database_name
	table_name										= each.value.table_name

	dynamic "schema" {
		for_each									= each.value.schema

		content {
			composite_partition_key {
				enforcement_in_record				= each.value.schema.enforcement_in_record
				name								= each.value.schema.name
				type								= each.value.schema.type
			}
		}
	}

	dynamic "magnetic_store_write_properties" {
		for_each									= each.value.magnetic_store_write_properties

		content {		
			enable_magnetic_store_writes			= each.value.enable_magnetic_store_writes

			dynamic "magnetic_store_rejected_data_location" {
				for_each							= each.value.magnetic_store_rejected_data_location

				content {
					s3_configuration {
						bucket_name					= each.value.magnetic_store_rejected_data_location.bucket_name
						encryption_option			= each.value.magnetic_store_rejected_data_location.is_encryption_option_sse_s3 ? "SSE_S3" : "SSE_KMS"
						kms_key_id					= each.value.magnetic_store_rejected_data_location.ksm_key_arn
						object_key_prefix			= each.value.magnetic_store_rejected_data_location.object_key_prefix
					}
				}
			}
		}
	}

	retention_properties {
		magnetic_store_retention_period_in_days 	= each.value.retention_memory_store
		memory_store_retention_period_in_hours  	= each.value.retention_magnetic_store
	}

	tags 											= merge(var.tags, each.value.tags)
}