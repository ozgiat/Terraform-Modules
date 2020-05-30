# Oz Giat
# Requirments
###############################
#Inputs:
# env-name
# vpc_region
###############################

provider "aws" {
  shared_credentials_file = CREDENTIALS
  profile                 = "default"
  region                  = "eu-west-3"
}
resource "aws_sqs_queue" "new_queue_dead_letter" {
  for_each = toset(var.queues)
  name                      = "${var.env-name}-${each.key}-deadLetter"
  delay_seconds             = 0 
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
}

resource "aws_sqs_queue" "new_queue" {
  for_each = toset(var.queues)
  name                      = "${var.env-name}-${each.key}"
  delay_seconds             = "0" 
  max_message_size          = "262144" 
  message_retention_seconds = "345600" 
  receive_wait_time_seconds = "0"
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.new_queue_dead_letter[each.key].arn}\",\"maxReceiveCount\":4}"
}

############### Test your outputs ################
output "queues" { 
  value = aws_sqs_queue.new_queue
}
##################################################

