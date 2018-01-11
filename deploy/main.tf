resource "aws_lambda_function" "form_handler_lambda" {
    function_name = "form_handler_lambda"
    handler = "index.handler"
    runtime = "nodejs6.10"
    filename = "../dist/function.zip"
    source_code_hash = "${base64sha256(file("../dist/function.zip"))}"
    role = "${aws_iam_role.lambda_exec_role.arn}"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  assume_role_policy = "${file("policies/lambda-role.json")}"
}

resource "aws_lambda_permission" "allow_api_gateway" {
  function_name = "${aws_lambda_function.form_handler_lambda.arn}"
  statement_id = "AllowExecutionFromApiGateway"
  action = "lambda:InvokeFunction"
  principal = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.form_handler_api.id}/*/${aws_api_gateway_method.form_handler_api_method.http_method}${aws_api_gateway_resource.form_handler_api_resource.path}"
}

resource "aws_api_gateway_rest_api" "form_handler_api" {
  name = "FormHandlerAPI"
  description = "Form Handler Rest Api"
}

resource "aws_api_gateway_resource" "form_handler_api_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.form_handler_api.id}"
  parent_id = "${aws_api_gateway_rest_api.form_handler_api.root_resource_id}"
  path_part = "forms"
}

resource "aws_api_gateway_method" "form_handler_api_method" {
  rest_api_id = "${aws_api_gateway_rest_api.form_handler_api.id}"
  resource_id = "${aws_api_gateway_resource.form_handler_api_resource.id}"
  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "form_handler_api_method-integration" {
  rest_api_id = "${aws_api_gateway_rest_api.form_handler_api.id}"
  resource_id = "${aws_api_gateway_resource.form_handler_api_resource.id}"
  http_method = "${aws_api_gateway_method.form_handler_api_method.http_method}"
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${aws_lambda_function.form_handler_lambda.function_name}/invocations"
  integration_http_method = "POST"
}

resource "aws_api_gateway_deployment" "form_handler_deployment_dev" {
  depends_on = [
    "aws_api_gateway_method.form_handler_api_method",
    "aws_api_gateway_integration.form_handler_api_method-integration"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.form_handler_api.id}"
  stage_name = "dev"
}

resource "aws_api_gateway_deployment" "form_handler_deployment_prod" {
  depends_on = [
    "aws_api_gateway_method.form_handler_api_method",
    "aws_api_gateway_integration.form_handler_api_method-integration"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.form_handler_api.id}"
  stage_name = "api"
}

output "dev_url" {
  value = "https://${aws_api_gateway_deployment.form_handler_deployment_dev.rest_api_id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_deployment.form_handler_deployment_dev.stage_name}"
}

output "prod_url" {
  value = "https://${aws_api_gateway_deployment.form_handler_deployment_prod.rest_api_id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_deployment.form_handler_deployment_prod.stage_name}"
}
