variable "should_create_database" {
	description 							= "(Optional) Should create timestream database. (default false)."
	type									= bool
	default									= false
}

variable "database_name" {
	description								= "(Required) The name of the Timestream database. Minimum length of 3. Maximum length of 64."
	type									= string
}

variable "kms_key_arn" {
	description 							= " (Optional) The ARN (not Alias ARN) of the KMS key to be used to encrypt the data stored in the database. If the KMS key is not specified, the database will be encrypted with a Timestream managed KMS key located in your account."
	type									= string
	default									= null
}

variable "tags" {
	description 							= "(Optional) Map of tags to assign to the all resources in module."
	type									= map(string)
	default									= {}
}

variable "timestream_tables" {
  description								= "List of tables to be created in Timestream"
  type        								= map(object({
    retention_memory_store					= optional(number, 1)
    retention_magnetic_store				= optional(number, 1)
	table_name								= string
	enable_magnetic_store_writes			= optional(bool, false)
	magnetic_store_rejected_data_location 	= optional(object({
		bucket_name							= optional(string) 
		is_encryption_option_sse_s3			= optional(bool)
		ksm_key_arn							= optional(string) 
		object_key_prefix					= optional(string) 
	}), null)
	schema									= object({
		composite_partition_key				= list(object({
			name							= optional(string)
			type							= string
			enforcement_in_record			= optional(string)
		}))
	})
  }))
}