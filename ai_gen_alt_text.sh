#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 IMAGE [PROMPT]" >&2
    exit 1
fi

IMAGE="$1"
PROMPT="${2:-Describe this image in one short sentence.}"

if [ ! -f "${IMAGE}" ]; then
    echo "Error: '${IMAGE}' is not a file" >&2
    exit 1
fi

if [ -z "${OPENAI_API_KEY:-}" ]; then
    echo "Error: OPENAI_API_KEY is not set" >&2
    exit 1
fi

# Guess mime type (fallback to jpeg)
MIME_TYPE=$(file --mime-type -b "${IMAGE}" 2>/dev/null || echo "image/jpeg")

B64=$(base64 -w0 "${IMAGE}")

curl -sS https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer ${OPENAI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d @- <<EOF | jq -r '.choices[0].message.content'
{
  "model": "gpt-4o-mini",
  "messages": [
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "${PROMPT}"
        },
        {
          "type": "image_url",
          "image_url": {
            "url": "data:${MIME_TYPE};base64,${B64}"
          }
        }
      ]
    }
  ]
}
EOF
