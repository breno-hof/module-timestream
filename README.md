# AWS Timestream Terraform Module

This Terraform module provisions an AWS Timestream database along with tables and associated configurations.

## Features

- Creates a Timestream database (optional)
- Supports KMS encryption
- Allows provisioning multiple tables with retention policies
- Configurable table schemas and magnetic store settings
- Supports tagging of all resources

## Usage

```hcl
module "timestream" {
	source 										= "github.com/breno-hof/module-timestream//src?ref=1.0.1"

	should_create_database 						= true

	database_name       						= "pool_timestream_db"

	timestream_tables 							= {
		example_table 							= {
			table_name                   		= "pool_sensor_events"
			retention_memory_store        		= 86400  # 1 day
			retention_magnetic_store      		= 31536000 # 1 year
			schema 								= {
				composite_partition_key 		= [
					{
						name                 	= "device_id"
						type                 	= "VARCHAR"
						enforcement_in_record 	= "REQUIRED"
					}
				]
			}
		}
	}


	tags										= {
		GitHubRepo								= "infra-pool-timestream"
	}
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `should_create_database` | Should create the Timestream database. | `bool` | `false` | No |
| `database_name` | Name of the Timestream database. | `string` | n/a | Yes |
| `kms_key_arn` | ARN of the KMS key used for encryption. | `string` | `null` | No |
| `tags` | Tags to assign to all resources. | `map(string)` | `{}` | No |
| `timestream_tables` | Map of tables to create with configurations. | `map(object({...}))` | `null` | No |

### `timestream_tables` Object Schema

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `table_name` | Name of the Timestream table. | `string` | n/a |
| `retention_memory_store` | Retention period for in-memory storage (seconds). | `number` | `null` |
| `retention_magnetic_store` | Retention period for magnetic storage (seconds). | `number` | `null` |
| `tags` | Tags assigned to the table. | `map(string)` | `{}` |
| `enable_magnetic_store_writes` | Enable writes to magnetic storage. | `bool` | `false` |
| `magnetic_store_rejected_data_location` | Configuration for rejected data location in magnetic store. | `object` | `null` |
| `bucket_name` | S3 bucket name for rejected data storage. | `string` | `null` |
| `is_encryption_option_sse_s3` | Whether to use SSE-S3 encryption. | `bool` | `null` |
| `ksm_key_arn` | KMS Key ARN for encryption. | `string` | `null` |
| `object_key_prefix` | Prefix for object keys in S3 bucket. | `string` | `null` |
| `schema` | Schema definition for the table. | `object` | `null` |
| `composite_partition_key` | Composite partition key details. | `list(object)` | `null` |
| `name` | Name of the partition key. | `string` | `null` |
| `type` | Data type of the partition key. | `string` | `null` |
| `enforcement_in_record` | Enforcement level in records. | `string` | `null` |

## Outputs

| Name | Description |
|------|-------------|
| `aws_timestream_database_arn` | ARN of the Timestream database. |
| `aws_timestream_database_table_count` | Total number of tables in the database. |
| `aws_timestream_database_kms_key_arn` | ARN of the KMS key used for encryption. |
| `aws_timestream_table_id` | Map of table IDs with `database_name:table_name` format. |
| `aws_timestream_table_arn` | Map of ARNs identifying the tables. |

## Requirements

- Terraform 1.0+
- AWS Provider 4.0+

## License

This project is licensed under the GNU License - see the LICENSE file for details.
