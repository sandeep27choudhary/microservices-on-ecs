import json
import os
import requests

def send_slack_message(message):
    slack_webhook_url = os.getenv('SLACK_WEBHOOK_URL')
    headers = {'Content-type': 'application/json'}
    response = requests.post(slack_webhook_url, headers=headers, data=json.dumps({'text': message}))

    if response.status_code != 200:
        raise ValueError(f'Request to Slack returned an error {response.status_code}, the response is:\n{response.text}')

def send_teams_message(message, color):
    teams_webhook_url = os.getenv('TEAMS_WEBHOOK_URL')
    headers = {'Content-type': 'application/json'}
    message = {
        "@type": "MessageCard",
        "@context": "http://schema.org/extensions",
        "themeColor": color,
        "summary": "Health Check Status",
        "sections": [{
            "activityTitle": "Health Check Status",
            "text": message
        }],
        "potentialAction": [{
            "@type": "OpenUri",
            "name": "Details",
            "targets": [{"os": "default", "uri": "https://console.aws.amazon.com/route53/healthchecks/home#"}]
        }]
    }
    response = requests.post(teams_webhook_url, headers=headers, data=json.dumps(message))

    if response.status_code != 200:
        raise ValueError(f'Request to Teams returned an error {response.status_code}, the response is:\n{response.text}')


def handler(event, context):
    alarm_message = json.loads(event['Records'][0]['Sns']['Message'])
    endpoint = alarm_message['AlarmDescription']  # Assumes the endpoint URL is in the AlarmDescription

    if alarm_message['NewStateValue'] == 'ALARM':
        formatted_message_slack = f"*Endpoint:* {endpoint}\n" \
                            f"*State:* :elmofire: endpoint health check failed :warning:\n" \
                            f"<https://console.aws.amazon.com/route53/healthchecks/home#|Details>"
        formatted_message_teams = f"{endpoint} health check failed!"
        teams_color = "FF0000"  # Red
    elif alarm_message['NewStateValue'] == 'OK':
        formatted_message_slack = f"*Endpoint:* {endpoint}\n" \
                            f"*State:* :baby-yoda-soup: endpoint recovered :white_check_mark:\n" \
                            f"<https://console.aws.amazon.com/route53/healthchecks/home#|Details>"
        formatted_message_teams = f"{endpoint} health check is ok!"
        teams_color = "00FF00"  # Green

    slack_webhook_url = os.getenv('SLACK_WEBHOOK_URL')
    teams_webhook_url = os.getenv('TEAMS_WEBHOOK_URL')

    if slack_webhook_url and slack_webhook_url.strip():
        send_slack_message(formatted_message_slack)
    if teams_webhook_url and teams_webhook_url.strip():
        send_teams_message(formatted_message_teams, teams_color)