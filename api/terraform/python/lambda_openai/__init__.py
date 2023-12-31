# -*- coding: utf-8 -*-
# pylint: disable=duplicate-code
"""Lambda function for OpenAI API."""
import os

from dotenv import find_dotenv, load_dotenv


# Load environment variables from .env file in all folders
dotenv_path = find_dotenv()
if os.path.exists(dotenv_path):
    load_dotenv(dotenv_path=dotenv_path, verbose=True)
    OPENAI_API_KEY = os.environ["OPENAI_API_KEY"]
    OPENAI_API_ORGANIZATION = os.environ["OPENAI_API_ORGANIZATION"]
    PINECONE_API_KEY = os.environ["PINECONE_API_KEY"]
else:
    raise FileNotFoundError("No .env file found in root directory of repository")
