#!/bin/bash
##
## Send notifications with Firebase Cloud Messaging HTTP protocol
##
## Include this file into your project and adjust api_key
## Documentation at https://firebase.google.com/docs/cloud-messaging/http-server-ref
##
## Usage: send_fcm_notification [options]
##
## Options:
##  --category <string>     Set priority category of notification
##  --channel <string>      Set notification channel of notification
##  --image <string>        Set image to be displayed in notification
##  --message <string>      Set message to be displayed in notification
##  --priority <int>        Set default or high priority of notification
##  --receiver <string>     Set receiver(s) in space-separated string
##  --summary-id <int>      Set summaryId for grouping of notification
##  --time-to-live <int>    Set time-to-live (in days) for to-be delivered notification
##  --title <string>        Set title to be displayed in notification
##  --topic <string>        Set subscription topic instead of receiver(s)
##  --url <string>          Set url for main click action in notification

function error_exit
{
  echo "ERROR: $1" 1>&2
  exit 1
}

function send_fcm_notification
{
  # Set your API key for Firebase Cloud Messaging
  local api_key=''

  ########
  ## Get variables from named parameters
  ########
  while [[ "$#" -gt 1 ]]
  do
    if [[ "$2" != *"--"* ]]
    then
      case $1 in
        --category)
          local category=$2
        ;;
        --channel)
          local channel=$2
        ;;
        --image)
          local image=$2
        ;;
        --message)
          local message=$2
        ;;
        --priority)
          local priority=$2
        ;;
        --receiver)
          local receiver=$2
        ;;
        --summary-id)
          local summaryid=$2
        ;;
        --time-to-live)
          local timetolive=$2
        ;;
        --title)
          local title=$2
        ;;
        --topic)
          local topic=$2
        ;;
        --url)
          local url=$2
        ;;
      esac
    fi
    shift
  done

  ########
  ## Validate API key
  ########
  if [ -z "$api_key" ]
  then
    error_exit "You forgot to set your FCM API key in FirebaseCloudMessaging.sh"
  fi

  ########
  ## Validate receiver and topic parameter
  ########
  if [ "$receiver" ] && [ "$topic" ]
  then
    error_exit "You cannot set both --receiver and --topic"
  elif [ -z "$receiver" ] && [ -z "$topic" ]
  then
    error_exit "You must set either --receiver or --topic"
  elif [ "$topic" ]
  then
    if [[ "$topic" != "/topics/"* ]]
    then
      error_exit "--topic must be prefixed with \"/topics/\""
    else
      local to='to'
      local receiver="$topic"
    fi
  elif [ "$receiver" ]
  then
    local to='registration_ids'
    receiver=${receiver// /\",\"}
  fi

  ########
  ## Validate category parameter
  ########
  if [ "$category" ]
  then
    case "$category" in
      "alarm"|"call"|"email"|"err"|"event"|"msg"|"navigation"|"progress"|"promo"|"recommendation"|"reminder"|"service"|"social"|"status"|"transport")
      ;;
      *)
        error_exit "--category must be one of these categories: alarm, call, email, err, event, msg, navigation, progress, promo, recommendation, reminder, service, social, status, transport"
      ;;
    esac
  else
    error_exit "--category is not set"
  fi

  ########
  ## Validate channel parameter
  ########
  if [ -z "$channel" ]
  then
    error_exit "--channel is not set"
  fi

  ########
  ## Validate image parameter
  ########
  if [ -z "$image" ]
  then
    error_exit "--image is not set"
  elif [[ "$image" != "http"* ]]
  then
    error_exit "--image has no valid address"
  fi

  ########
  ## Validate message parameter
  ########
  if [ -z "$message" ]
  then
    error_exit "--message is not set"
  else
    local message
    message=$(echo "$message" | cut -c 1-110)
  fi

  ########
  ## Validate priority parameter
  ########
  if [ -z "$priority" ]
  then
    error_exit "--priority is not set"
  elif [ "$priority" -ne 0 ] && [ "$priority" -ne 1 ]
  then
    error_exit "--priority must be 0 or 1"
  fi

  ########
  ## Validate summary id parameter
  ########
  if [ -z "$summaryid" ]
  then
    error_exit "--summary-id is not set"
  elif [ "$summaryid" -ne "$summaryid" ]
  then
    error_exit "--summary-id must be an integer"
  fi

  ########
  ## Validate time-to-live parameter
  ########
  if [ "$timetolive" ] && [ "$timetolive" -eq "$timetolive" ]
  then
    if [ "$timetolive" -ge 1 ] && [ "$timetolive" -le 28 ]
    then
      local timetolive
      timetolive=$((timetolive*60*60*24))
    else
      error_exit "--timetolive must be between 1 and 28 days"
    fi
  else
    local timetolive
    timetolive=$((28*60*60*24))
  fi

  ########
  ## Validate title parameter
  ########
  if [ -z "$title" ]
  then
    error_exit "--title is not set"
  fi

  ########
  ## Validate url parameter
  ########
  if [ -z "$url" ]
  then
    error_exit "--url is not set"
  elif [[ "$url" != "http"* ]]
  then
    error_exit "--url has no valid address"
  fi

  ########
  ## Put data in json format
  ########
  local data
  data=$(cat <<-EOF
    {
      "$to": [
        "$receiver"
      ],
      "time_to_live": $timetolive,
      "data": {
        "category": "$category",
        "channel": "$channel",
        "image": "$image",
        "message": "$message",
        "notificationId": $(shuf -i111111111-999999999 -n1),
        "priority": $priority,
        "summaryId": $summaryid,
        "title": "$title",
        "url": "$url"
      }
    }
EOF
  )

  ########
  ## Send the notification and get response code back
  ########
  curl --data "$data" \
    --fail \
    --header "Authorization: key=$api_key" \
    --header "Content-Type: application/json" \
    --location \
    --request POST \
    --silent \
    'https://fcm.googleapis.com/fcm/send'
}
