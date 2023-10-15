// see https://github.com/FullStackWithLawrence/aws-openai/blob/main/api/terraform/apigateway_endpoints.tf#L19
import { BACKEND_API_URL, AWS_API_GATEWAY_KEY, OPENAI_EXAMPLES_URL } from "../config";

const SLUG = 'default-emoji-chatbot';

const Emojibot4 = {
  api_url: BACKEND_API_URL + SLUG,
  api_key: AWS_API_GATEWAY_KEY,
  app_name: "Emojibot",
  assistant_name: "Matilda",
  avatar_url: '/applications/Emojibot4/Matilda.svg',
  background_image_url: '/applications/Emojibot4/Emojibot4-bg.jpg',
  welcome_message: `Hello, I'm Matilda, a mime who only responds with emojis. Let's chat!`,
  example_prompts: [
    "What's shake'n bacon",
    '"Lets go on a magic carpet ride"',
    '"Shooby dooby doo, where are are you"',
  ],
  placeholder_text: `say something to Matilda`,
  info_url: OPENAI_EXAMPLES_URL + SLUG
};

export default Emojibot4;