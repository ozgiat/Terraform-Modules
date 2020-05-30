variable "env-name" {
  default ="digital"
}

variable "vpc_region" {
  default = ""
}

variable "queues" {
  type = list(string)
  default = [
    "queue-1",
    "queue-2",
    "queue-3",
    "queue-4",
    "queue-5"
  ]
}

