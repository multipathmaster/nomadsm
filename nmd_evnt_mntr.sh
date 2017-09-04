#!/bin/bash
#WRITTEN BY MULTIPATHMASTER BECAUSE BASH IS STILL AWESOME

#VARS
#PUT YOUR NOMAD IP/HOSTNAME HERE
SERV="${NOMAD_JOB_IPHN}"

debugger(){
set -x
}

#THIS GETS CALLED UPON BY THE DEAD_MAN_SWITCH AND FEEDS THE ARGUMENTS CONFIGURED PER MONITORING TYPE
TYPE=$1

#HOW THESE WORK:  A SIMPLE GET FROM NOMAD API FRONTEND, SOME FILTERING W/ JQ
#SOME GREPS AND OTHER NEFARIOUS THINGS TO GATHER OVERALL JOB STATUS
#IF AN ALERT MATCHES IT GOES INSIDE AN INTERNAL WHILE LOOP, AND AS LONG
#AS IT STILL MATCHES THE CONDITION, WILL ALERT EVERY 5 MINUTES
#THE ECHO STATMENTS ARE MEANINGFUL IF YOU RUN DEADMAN WITH LOUD ARGUMENT

queued_checker(){
while : ; do
  if [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Queued" | grep -v 0 | wc -l` -gt 0 ]]; then
    while [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Queued" | grep -v 0 | wc -l` -gt 0 ]]; do
      /usr/local/bin/slack_alert.sh queued
      sleep 300
    done
  else
    until [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Queued" | grep -v 0 | wc -l` -ne 0 ]]; do
      echo "INFO: Not Detecting..."
      echo "INFO: Sleeping..."
      sleep 1
      if [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Queued" | grep -v 0 | wc -l` -gt 0 ]]; then
        while [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Queued" | grep -v 0 | wc -l` -gt 0 ]]; do
          /usr/local/bin/slack_alert.sh queued
          sleep 300
        done
      else
        echo "INFO: Everything normal in sub loop checker Queued."
        echo "INFO: Loop Phase..."
      fi
    done
  fi
done
}

failed_checker(){
while : ; do
  if [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Failed" | grep -v 0 | wc -l` -gt 0 ]]; then
    while [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Failed" | grep -v 0 | wc -l` -gt 0 ]]; do
      /usr/local/bin/slack_alert.sh failed
      sleep 300
    done
  else
    until [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Failed" | grep -v 0 | wc -l` -ne 0 ]]; do
      echo "INFO: Not Detecting..."
      echo "INFO: Sleeping..."
      sleep 1
      if [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Failed" | grep -v 0 | wc -l` -gt 0 ]]; then
        while [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Failed" | grep -v 0 | wc -l` -gt 0 ]]; do
          /usr/local/bin/slack_alert.sh failed
          sleep 300
        done
      else
        echo "INFO: Everything normal in sub loop checker Failed."
        echo "INFO: Next Loop Phase..."
      fi
    done
  fi
done
}

starting_checker(){
until [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Starting" | grep -v 0 | wc -l` -ne 0 ]]; do
echo "INFO: Not Detecting..."
echo "INFO: Sleeping..."
sleep 1
  if [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Starting" | grep -v 0 | wc -l` -ne 0 ]]; then
    echo "ALERT: ALERTING, BREAKING LOOP TO ALERT."
    break
  else
    echo "INFO: Everything normal in sub loop checker..."
    echo "INFO: Next Loop Phase..."
  fi
done
}

lost_checker(){
while : ; do
  if [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Lost" | grep -v 0 | wc -l` -gt 0 ]]; then
    while [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Lost" | grep -v 0 | wc -l` -gt 0 ]]; do
      /usr/local/bin/slack_alert.sh lost
      sleep 300
    done
  else
    until [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Lost" | grep -v 0 | wc -l` -ne 0 ]]; do
      echo "INFO: Not Detecting..."
      echo "INFO: Sleeping..."
      sleep 1
      if [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Lost" | grep -v 0 | wc -l` -gt 0 ]]; then
        while [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Lost" | grep -v 0 | wc -l` -gt 0 ]]; do
          /usr/local/bin/slack_alert.sh lost
          sleep 300
        done
      else
        echo "INFO: Everything normal in sub loop checker Lost."
        echo "INFO: Next Loop Phase..."
      fi
    done
  fi
done
}

complete_checker(){
until [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Complete" | grep -v 0 | wc -l` -ne 0 ]]; do
echo "INFO: Not Detecting..."
echo "INFO: Sleeping..."
sleep 1
  if [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Complete" | grep -v 0 | wc -l` -ne 0 ]]; then
    echo "ALERT: ALERTING, BREAKING LOOP TO ALERT."
    break
  else
    echo "INFO: Everything normal in sub loop checker..."
    echo "INFO: Next Loop Phase..."
  fi
done
}

running_checker(){
while : ; do
  if [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Running" | grep -v 0 | wc -l` == 0 ]]; then
    echo "ALERT: ALERTING, THERE ARE NO RUNNING JOBS."
    while [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Running" | grep -v 0 | wc -l` == 0 ]]; do
      /usr/local/bin/slack_alert.sh running
      sleep 300
    done
  else
    until [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Running" | grep -v 0 | wc -l` == 0 ]]; do
      echo "INFO: Not Detecting..."
      echo "INFO: Sleeping..."
      sleep 1
      if [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Running" | grep -v 0 | wc -l` == 0 ]]; then
        echo "ALERT: ALERTING, THERE ARE NO RUNNING JOBS."
          while [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Running" | grep -v 0 | wc -l` == 0 ]]; do
            /usr/local/bin/slack_alert.sh running
            sleep 300
          done
      else
        echo "INFO: Everything normal in sub loop checker Running."
        echo "INFO: Next Loop Phase..."
      fi
    done
  fi
done
}

#HERE WE ARE CALLING UPON THE DIFFERNT TYPES TO SPAWN DIFFERENT PIDS
#FEEL FREE TO ADD MORE TYPES AND OTHER CURLS TO THE INTERFACE
#TRIED TO MAKE THIS AS CAVEMAN TO THE 'NIX USER AS POSSIBLE
#DEADMAN CALLS THIS HENCE THE EXIT 187 IN THE ELSE
main(){
if [[ ${TYPE} == "queued" ]]; then
  queued_checker
elif [[ ${TYPE} == "failed" ]]; then
  failed_checker
elif [[  ${TYPE} == "running" ]]; then
  running_checker
elif [[ ${TYPE} == "starting" ]]; then
  starting_checker
elif [[ ${TYPE} == "lost" ]]; then
  lost_checker
elif [[ ${TYPE} == "complete" ]]; then
  complete_checker
else
  echo "Unsure WTF just happened."
  exit 187
fi
}

debugger
main $@
