# nomadsm (Nomad Slack Monitoring Service)
A 10MB container/service for sending alerts to Slack for common Nomad job problems/issues.<br>
https://hub.docker.com/r/multipathmaster/nomadsm <br>
<br>
<img src=https://raw.githubusercontent.com/multipathmaster/nomadsm/master/img/SLACK_ALERT.png><br>
#QUICK OVERVIEW:<br>
this deployment assumes you have hashi-ui or some other fork/clone running.<br>
docker-entrypoint.sh is the entrypoint. It calls upon dead_man_switch.sh.<br>
dead_man_switch.sh starts the nmd_evnt_mntr.sh instances, as well a providing other options.<br>
nmd_evnt_mntr.sh is a collection of event monitors that call upon slack_alert.sh once a condition is met.<br>
slack_alert.sh is the alerting mechanism.<br>

#BREAK UP INSTANCES OR SINGLE CONTAINER QUESTION?:
1.  comment out all the monitors but one in dead_man_switch.sh
2.  build the image and name it appropriately for that specific check.
3.  build another one with a different one uncommented, name it appropriately, so on and so forth.
4.  alternatively just run the bash scripts on a live host? but defeating fault tolerance of a task scheduler.<br>

#HA PLAN?:
1.  if you plan on running this on your hashicorp stack (consul/nomad), it would be wise to already have multiple datacenters setup, run this on one DC that is separate from the other, otherwise the "Running" check will not work if the very container/service that is monitoring the DC is also offline as well.  so if you have 2 DCs, run 2 of these instances, but point them to the nomad IPs/HOSTNAMES of the opposite DCs.  if you have 3 DCs, you will need at least 4 instances, and after that, you should probably dedicate a DC solely for monitoring the rest of the configured REGION/REGIONS.<br>

STEPS FOR SOLO DEPLOYMENT:
1.  `docker build .` OR `docker pull multipathmaster/nomadsm`
2.  `docker tag "ID FROM ABOVE" "NEW NAME"` IGNORE IF DOCKER PULL
3.  `docker run -it -e NOMAD_JOB_IPHN='http://NOMAD_SERVER_IP:4646/v1/jobs' -e NOMAD_SRV_JOB_PATH='http://NOMAD_SERVER_IP:3000/nomad/REGION/jobs' -e S_CHAN='CHAN_NAME_WO_#' -e S_USRNM='BOT_NAME' -e S_HOOK='https://hooks.slack.com/services/YOUR/TOKEN/HERE' -e S_PROXY='http://YOUR.PROXY.HERE:PORT/' "NEW IMAGE NAME"` OR `multipathmaster/nomadsm` NOTE: THE PROXY IS OPTIONAL ONLY IF YOU NEED IT
4.  `docker ps #FIND CONTAINER`
5.  `docker exec -it "CONTAINER" bash`

STEPS FOR DEPLOYING ON THE HASHICORP STACK: (CONSUL/NOMAD):
1.  `docker build .` OR `docker pull multipathmaster/nomadsm`
2.  `docker tag "ID FROM ABOVE" "NEW NAME"`
3.  export the image however you wish and place it in a repo.  i use a local repo w/ a simple registry container on
port 5000.  i.e. you can use artifactory or something similar instead.  Or use multipathmaster/nomadsm.
4.  copy the below config into nomadsm.nomad (or whatever_name_you_wish.nomad/json/etc...)
```
job "nomadsm" {
  region = "YOUR_REGION"
  datacenters = ["YOUR_DC"]
  type = "service"
   constraint {
     attribute = "${attr.kernel.name}"
     value     = "linux"
   }
  update {
    stagger = "15s"
    max_parallel = 1
  }
  group "nomadsm" {
    count = 1
    constraint {
      operator = "distinct_hosts"
      value    = "true"
    }
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }
    ephemeral_disk {
      size = 128
    }
    task "nomadsm" {
      driver = "docker"
      config {
        image = "multipathmaster/nomadsm:latest"
        network_mode = "host"
        port_map = {
        }
        #volumes = [ "" ]
      }
      env {
        NOMAD_JOB_IPHN="http://NOMAD_SERVER_IP:4646/v1/jobs"
        NOMAD_SRV_JOB_PATH="http://NOMAD_SERVER_IP:3000/nomad/REGION/jobs"
        S_CHAN="SLACK_CHANNEL_WO_#"
        S_USRNM="BOT_NAME"
        S_HOOK="https://hooks.slack.com/services/YOUR/TOKEN/HERE"
        S_PROXY="http://YOUR.PROXY.HERE:PORT/" #OPTIONAL ONLY IF YOU NEED THIS
      }
      resources {
        cpu    = 32
        memory = 64
        network {
          mbits = 10
        }
      }
      service {
        name = "nomadsm"
        tags = ["nomadsm"]
        #port = "nomadsm"
        #check {
        #  name     = "alive"
        #  type     = "tcp"
        #  interval = "15s"
        #  timeout  = "3s"
        #}
      }
    }
  }
}
```
5.  `nomad plan nomadsm.nomad`
6.  make any adjustments to the plan as you see fit(i.e. task/group/resources/service changes).
7.  `nomad run nomadsm.nomad` <br>
<br>
<img src=https://raw.githubusercontent.com/multipathmaster/nomadrcm/master/img/Nomad_Running.png>
<br>
<img src=https://raw.githubusercontent.com/multipathmaster/nomadrcm/master/img/stderr.png>
<br>
<img src=https://raw.githubusercontent.com/multipathmaster/nomadrcm/master/img/stdout.png>
<br>
