output "aws_timestream_database_arn" {
	description = "The ARN that uniquely identifies this database."
	value		= var.should_create_database ? aws_timestreamwrite_database.this[0].arn : null
}

output "aws_timestream_database_table_count" {
	description = "The total number of tables found within the Timestream database."
	value		= var.should_create_database ? aws_timestreamwrite_database.this[0].table_count : null
}

output "aws_timestream_database_kms_key_arn" {
	description = "The ARN of the KMS key used to encrypt the data stored in the database."
	value		= var.should_create_database ? aws_timestreamwrite_database.this[0].kms_key_id : null
}


output "aws_timestream_table_id" {
	description = "The table_name and database_name separated by a colon (:)."
	value = {
		for table_id, table in aws_timestreamwrite_table.this : table_id => table.id
	}
}

output "aws_timestream_table_arn" {
	description = "The ARN that uniquely identifies this table."
	value		= {
		for table_id, table in aws_timestreamwrite_table.this : table_arn => table.arn
	}
}