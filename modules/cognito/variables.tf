variable "env" {
  type = string
}

variable "project_name" {
  type = string
}

variable "tags" {
  type = map(string)
  default = {
    map-migrated = "d-server-03chi6j8h6vs1j"
  }
}

variable "cognito_callback_urls" {
    type = list 
}

variable "cognito_logout_urls" {
    type = list
}

variable "account_id" {
  type = string
}

variable "appsync_graphql_api_id" {
  type = string
}