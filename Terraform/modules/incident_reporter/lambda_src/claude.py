import json
import boto3

_BEDROCK = boto3.client("bedrock-runtime")


def invoke_claude(model_id: str, system_prompt: str, user_prompt: str) -> str:
    body = {
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 2000,
        "temperature": 0.2,
        "system": system_prompt,
        "messages": [
            {"role": "user", "content": [{"type": "text", "text": user_prompt}]}
        ],
    }

    resp = _BEDROCK.invoke_model(
        modelId=model_id,
        contentType="application/json",
        accept="application/json",
        body=json.dumps(body),
    )
    payload = json.loads(resp["body"].read())
    text_parts = payload.get("content", [])
    return "\n".join(
        [part.get("text", "") for part in text_parts if part.get("type") == "text"]
    )
