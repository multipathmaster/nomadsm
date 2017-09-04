#!/bin/bash
#PUT YOUR NOMAD SERVER AND PATH VAR USE HASHI-UI ATM
NSERV="${NOMAD_SRV_JOB_PATH}"

#SLACK CHANNEL
CHANNEL="${S_CHAN}"

#SLACK USERNAME
USERNAME="${S_USRNM}"

#SLACK HOOK
SHOOK="${S_HOOK}"

#SLACK PROXY
SPROXY="${S_PROXY}"

#WHAT TYPE OF ALERT WILL NMD_EVNT_MNTR SEND TO THIS TOOL?
TYPE=$1

debugger(){
set -x
}
<http://'$(/usr/bin/cat /tmp/hostname-nomad.txt)':3000/nomad/THD/clients|DOWN AGENTS>='$(/usr/bin/cat /tmp/nomad-agent-down.txt)'
alerting(){
if [[ -n ${SPROXY} ]]; then
  if [[ ${TYPE} == zombie ]]; then
    curl -X POST --data-urlencode 'payload={ "channel": "#'$(echo ${CHANNEL})'", "username": "'$(echo ${USERNAME})'", "text": "Zombies!" }' ${SHOOK} -x ${SPROXY}
  elif [[ ${TYPE} == failed ]]; then
    curl -X POST --data-urlencode 'payload={ "channel": "#'$(echo ${CHANNEL})'", "username": "'$(echo ${USERNAME})'", "text": ":robot_face: ALERT: <'$(echo ${NSERV})'|FAILED JOBS>! :fire:", "icon_emoji": ":warning:" }' ${SHOOK} -x ${SPROXY}
  elif [[ ${TYPE} == lost ]]; then
    curl -X POST --data-urlencode 'payload={ "channel": "#'$(echo ${CHANNEL})'", "username": "'$(echo ${USERNAME})'", "text": ":robot_face: ALERT: <'$(echo ${NSERV})'|LOST JOBS>! :fire:", "icon_emoji": ":warning:" }' ${SHOOK} -x ${SPROXY}
  elif [[ ${TYPE} == running ]]; then
    curl -X POST --data-urlencode 'payload={ "channel": "#'$(echo ${CHANNEL})'", "username": "'$(echo ${USERNAME})'", "text": ":robot_face: ALERT: <'$(echo ${NSERV})'|NO RUNNING JOBS>! :fire:", "icon_emoji": ":warning:" }' ${SHOOK} -x ${SPROXY}
  elif [[ ${TYPE} == queued ]]; then
    curl -X POST --data-urlencode 'payload={ "channel": "#'$(echo ${CHANNEL})'", "username": "'$(echo ${USERNAME})'", "text": ":robot_face: ALERT: <'$(echo ${NSERV})'|QUEUED JOBS>! :fire:", "icon_emoji": ":warning:" }' ${SHOOK} -x ${SPROXY}
  else
    echo "Unsupported TYPE detected."
  fi
else
  if [[ ${TYPE} == zombie ]]; then
    curl -X POST --data-urlencode 'payload={ "channel": "#'$(echo ${CHANNEL})'", "username": "'$(echo ${USERNAME})'", "text": "Zombies!" }' ${SHOOK}
  elif [[ ${TYPE} == failed ]]; then
    curl -X POST --data-urlencode 'payload={ "channel": "#'$(echo ${CHANNEL})'", "username": "'$(echo ${USERNAME})'", "text": ":robot_face: ALERT: <'$(echo ${NSERV})'|FAILED JOBS>! :fire:", "icon_emoji": ":warning:" }' ${SHOOK}
  elif [[ ${TYPE} == lost ]]; then
    curl -X POST --data-urlencode 'payload={ "channel": "#'$(echo ${CHANNEL})'", "username": "'$(echo ${USERNAME})'", "text": ":robot_face: ALERT: <'$(echo ${NSERV})'|LOST JOBS>! :fire:", "icon_emoji": ":warning:" }' ${SHOOK}
  elif [[ ${TYPE} == running ]]; then
    curl -X POST --data-urlencode 'payload={ "channel": "#'$(echo ${CHANNEL})'", "username": "'$(echo ${USERNAME})'", "text": ":robot_face: ALERT: <'$(echo ${NSERV})'|NO RUNNING JOBS>! :fire:", "icon_emoji": ":warning:" }' ${SHOOK}
  elif [[ ${TYPE} == queued ]]; then
    curl -X POST --data-urlencode 'payload={ "channel": "#'$(echo ${CHANNEL})'", "username": "'$(echo ${USERNAME})'", "text": ":robot_face: ALERT: <'$(echo ${NSERV})'|QUEUED JOBS>! :fire:", "icon_emoji": ":warning:" }' ${SHOOK}
  else
    echo "Unsupported TYPE detected."
  fi
fi
}

main(){
alerting $@
}

debugger
main $@
