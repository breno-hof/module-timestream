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

	schema {
		dynamic "composite_partition_key" {
			for_each							= each.value.schema.composite_partition_key
			
			content {
				enforcement_in_record			= composite_partition_key.value.enforcement_in_record
				name							= composite_partition_key.value.name
				type							= composite_partition_key.value.type == "DIMENSION" ? "DIMENSION" : "MEASURE"
			}
		}
	}

	dynamic "magnetic_store_write_properties" {
		for_each									= each.value.enable_magnetic_store_writes ? [1] : []

		content {		
			enable_magnetic_store_writes			= each.value.enable_magnetic_store_writes

			dynamic "magnetic_store_rejected_data_location" {
				for_each							= each.value.magnetic_store_rejected_data_location != null ? [each.value.magnetic_store_rejected_data_location] : []

				content {
					s3_configuration {
						bucket_name					= magnetic_store_rejected_data_location.value.bucket_name
						encryption_option			= magnetic_store_rejected_data_location.value.magnetic_store_rejected_data_location.is_encryption_option_sse_s3 ? "SSE_S3" : "SSE_KMS"
						kms_key_id					= magnetic_store_rejected_data_location.value.magnetic_store_rejected_data_location.ksm_key_arn
						object_key_prefix			= magnetic_store_rejected_data_location.value.magnetic_store_rejected_data_location.object_key_prefix
					}
				}
			}
		}
	}

	retention_properties {
		magnetic_store_retention_period_in_days 	= each.value.retention_magnetic_store >= 1 && each.value.retention_magnetic_store <= 73000 ? each.value.retention_magnetic_store : 1
		memory_store_retention_period_in_hours  	= each.value.retention_memory_store >= 1 && each.value.retention_memory_store <= 8766 ? each.value.retention_memory_store : 1
	}

	tags											= var.tags

	depends_on = [ aws_timestreamwrite_database.this ]
}