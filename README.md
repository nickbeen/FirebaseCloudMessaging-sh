# FirebaseCloudMessaging-sh
Shell-based library for sending notifications with Firebase Cloud Messaging HTTP Protocol.
This library requires Curl and a valid API key for Firebase Cloud Messaging.
You may need to adjust the keys of the JSON object to match with your own project.

## Install
```bash
#!/bin/bash
#
# MyScript.sh
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Include the library
source "$DIR/FirebaseCloudMessaging.sh"

# Most basic implementation
send_fcm_notification "$@"
```

## Usage
```bash
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
```

## Examples
Send to single device with single --receiver argument
```bash
:~$ ./MyScript.sh \
  --category "msg" \
  --channel "directmessages" \
  --image "https://www.example.com/directmessage.jpg" \
  --message "You received a direct message from Tom Tucker" \
  --priority 1 \
  --receiver "hUJLWcd...SpNqWc" \
  --summary-id 1 \
  --title "New direct message" \
  --url "https://www.example.com/directmessages/13"
```

Send to multiple devices with space-separated --receiver argument
```bash
:~$ ./MyScript.sh \
  --category "social" \
  --channel "subscriptions" \
  --image "https://www.example.com/reply.jpg" \
  --message "Stewie replied on the thread 'Timemachine Issues'" \
  --priority 0 \
  --receiver "hUJLWcd...SpNqWc WdGtZJ...PJNWvZ RmZkWn...PwJvZW" \
  --summary-id 2 \
  --title "New reply on subscribed thread" \
  --url "https://www.example.com/threads/97"
```

Send to subscription topic with --topic argument
```bash
:~$ ./MyScript.sh \
  --category "event" \
  --channel "events" \
  --image "https://www.example.com/event.jpg" \
  --message "Quagfest is being held next saturday" \
  --priority 1 \
  --summary-id 3 \
  --title "New upcoming event" \
  --topic "/topics/events" \
  --url "https://www.example.com/events/66"
```
