variable "name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "cloud_watch_encryption_enabled" {
  description = "Whether to enable encryption for the CloudWatch logs"
  type        = bool
  default     = true
}

variable "cloud_watch_log_retention_in_days" {
  description = "The number of days to retain the CloudWatch logs"
  type        = number
  default     = 30
}