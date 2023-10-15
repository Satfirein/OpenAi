// see https://github.com/FullStackWithLawrence/aws-openai/blob/main/api/terraform/apigateway_endpoints.tf#L19
import { BACKEND_API_URL, AWS_API_GATEWAY_KEY, OPENAI_EXAMPLES_URL } from "../config";

const SLUG = 'default-fix-python-bugs';

const PythonDebugger = {
  api_url: BACKEND_API_URL + SLUG,
  api_key: AWS_API_GATEWAY_KEY,
  app_name: "Python Debugger",
  assistant_name: "Deborah",
  avatar_url: '/applications/PythonDebugger/Deborah.svg',
  background_image_url: '/applications/PythonDebugger/PythonDebugger-bg.svg',
  welcome_message: `Hello, I'm Deborah, and I can debug Python code.`,
  example_prompts: [],
  placeholder_text: `upload a Python file for Deborah to debug`,
  info_url: OPENAI_EXAMPLES_URL + SLUG
};

export default PythonDebugger;