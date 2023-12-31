#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date:   sep-2023
#
# usage:  create an AWS APIGateway REST API.
#
# see:    https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_model.html
#         https://developer.hashicorp.com/terraform/tutorials/aws/lambda-api-gateway
#------------------------------------------------------------------------------
locals {
  api_name                 = "${var.shared_resource_identifier}-api"
  apigateway_iam_role_name = "${var.shared_resource_identifier}-apigateway"
  iam_role_policy_name     = "${var.shared_resource_identifier}-apigateway"
}

data "aws_caller_identity" "current" {}

###############################################################################
# Top-level REST API resources
###############################################################################

# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api
resource "aws_api_gateway_rest_api" "openai" {
  name        = local.api_name
  description = "OpenAI example apps micro service"

  # Note: our api is used exclusively to upload images file, hence
  # we want ALL requests to be treated as 'binary'. An example
  # alternative to this might be, say, 'image/jpeg', 'image/png', etc.
  binary_media_types = [
    "image/jpeg",
    "image/png",
    "image/png",
    "audio/mpeg",
    "audio/x-mpeg-3",
    "video/mpeg",
    "video/x-mpeg",
    "multipart/form-data"
  ]
  api_key_source = "HEADER"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  tags = var.tags
}

resource "aws_api_gateway_resource" "examples" {
  path_part   = "examples"
  parent_id   = aws_api_gateway_rest_api.openai.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.openai.id
}

resource "aws_api_gateway_api_key" "openai" {
  name = var.shared_resource_identifier
  tags = var.tags
}


resource "aws_api_gateway_deployment" "openai" {
  rest_api_id = aws_api_gateway_rest_api.openai.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.openai.body,

      # 1 thru 10
      module.default_grammar.sha1_deployment_trigger,
      module.default_summarize.sha1_deployment_trigger,
      module.default_parse_data.sha1_deployment_trigger,
      module.default_emoji_translation.sha1_deployment_trigger,
      module.default_time_complexity.sha1_deployment_trigger,
      module.default_explain_code.sha1_deployment_trigger,
      module.default_keywords.sha1_deployment_trigger,
      module.default_product_name_gen.sha1_deployment_trigger,
      module.default_fix_python_bugs.sha1_deployment_trigger,
      module.default_spreadsheet_gen.sha1_deployment_trigger,

      # 11 thru 20
      module.default_tweet_classifier.sha1_deployment_trigger,
      module.default_airport_codes.sha1_deployment_trigger,
      module.default_mood_color.sha1_deployment_trigger,
      module.default_vr_fitness.sha1_deployment_trigger,
      module.default_marv_sarcastic_chat.sha1_deployment_trigger,
      module.default_turn_by_turn_directions.sha1_deployment_trigger,
      module.default_interview_questions.sha1_deployment_trigger,
      module.default_function_from_spec.sha1_deployment_trigger,
      module.default_code_improvement.sha1_deployment_trigger,
      module.default_single_page_website.sha1_deployment_trigger,

      # 21 thru 30
      module.default_rap_battle.sha1_deployment_trigger,
      module.default_memo_writer.sha1_deployment_trigger,
      module.default_emoji_chatbot.sha1_deployment_trigger,
      module.default_translation.sha1_deployment_trigger,
      module.default_socratic_tutor.sha1_deployment_trigger,
      module.default_sql_translate.sha1_deployment_trigger,
      module.default_meeting_notes_summarizer.sha1_deployment_trigger,
      module.default_review_classifier.sha1_deployment_trigger,
      module.default_pro_con_discusser.sha1_deployment_trigger,
      module.default_lesson_plan_writer.sha1_deployment_trigger
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}
# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage
resource "aws_api_gateway_stage" "openai" {
  deployment_id      = aws_api_gateway_deployment.openai.id
  cache_cluster_size = "0.5"
  rest_api_id        = aws_api_gateway_rest_api.openai.id
  stage_name         = var.stage
  tags               = var.tags
}

resource "aws_api_gateway_method_settings" "openai" {
  rest_api_id = aws_api_gateway_rest_api.openai.id
  stage_name  = aws_api_gateway_stage.openai.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled        = true
    data_trace_enabled     = true
    logging_level          = var.logging_level
    throttling_burst_limit = var.throttle_settings_burst_limit
    throttling_rate_limit  = var.throttle_settings_rate_limit
  }
}
resource "aws_api_gateway_usage_plan" "openai" {
  name        = var.shared_resource_identifier
  description = "Default usage plan"
  api_stages {
    api_id = aws_api_gateway_rest_api.openai.id
    stage  = aws_api_gateway_stage.openai.stage_name
  }
  quota_settings {
    limit  = var.quota_settings_limit
    offset = var.quota_settings_offset
    period = var.quota_settings_period
  }
  throttle_settings {
    burst_limit = var.throttle_settings_burst_limit
    rate_limit  = var.throttle_settings_rate_limit
  }
  tags = var.tags
}
resource "aws_api_gateway_usage_plan_key" "openai" {
  key_id        = aws_api_gateway_api_key.openai.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.openai.id
}


###############################################################################
# REST API resources - IAM
###############################################################################
resource "aws_iam_role" "apigateway" {
  name               = local.apigateway_iam_role_name
  description        = "Allows API Gateway to push files to an S3 bucket"
  assume_role_policy = file("${path.module}/json/iam_role_apigateway.json")
  tags               = var.tags
}
resource "aws_iam_role_policy" "iam_policy_apigateway" {
  name   = local.iam_role_policy_name
  role   = aws_iam_role.apigateway.id
  policy = file("${path.module}/json/iam_policy_apigateway.json")
}
resource "aws_iam_role_policy_attachment" "apigateway_CloudWatchFullAccess" {
  role       = aws_iam_role.apigateway.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

###############################################################################
# Cloudwatch logging
###############################################################################
resource "aws_cloudwatch_log_group" "apigateway" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_stage.openai.deployment_id}/v1"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}
