# -*- coding: utf-8 -*-
# pylint: disable=R0801
# flake8: noqa: F401
"""
Test requests to the OpenAI API using the Lambda Layer, 'genai'.
"""
import pytest  # pylint: disable=unused-import
from lambda_openai.tests.test_init import get_event, handle_event


# pylint: disable=too-few-public-methods
class TestOpenAIText:
    """Test the OpenAI API using the Lambda Layer, 'genai'."""

    def test_basic_request(self):
        """Test a basic request"""
        event = get_event("tests/events/test_01.request.json")
        retval = handle_event(event=event)
        print(retval)

        assert retval["statusCode"] == 200
        assert retval["body"]["object"] == "chat.completion"
        assert isinstance(retval["body"]["created"], int)
        assert retval["body"]["model"] == "gpt-3.5-turbo-0613"

        choice = retval["body"]["choices"][0]
        assert choice["index"] == 0
        assert choice["message"]["role"] == "assistant"
        assert choice["finish_reason"] == "stop"

        assert isinstance(retval["body"]["usage"]["prompt_tokens"], int)
        assert isinstance(retval["body"]["usage"]["completion_tokens"], int)
        assert isinstance(retval["body"]["usage"]["total_tokens"], int)
