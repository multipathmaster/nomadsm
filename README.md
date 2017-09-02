# nomadsm (Nomad Slack Monitoring Service)
A Nomad monitoring container for alerts in Slack for common job problems/issues.<br>
WRITTEN BY: MULTIPATHMASTER<br>
docker-entrypoint.sh is the entrypoint. It calls upon dead_man_switch.sh.<br>
dead_man_switch.sh starts the nmd_evnt_mntr.sh instances, as well a providing other options.<br>
nmd_evnt_mntr.sh is a collection of event monitors that call upon rocketc_alert.sh or slack_alert.sh once a condition is met.<br>
rocketc_alert.sh/slack_alert.sh are the alerting scripts.<br>
feel free to add your own for whatever you feel is necessary.<br>

#BREAK UP RESOURCES OR SINGLE CONTAINER QUESTION?:<br>
if you feel that the containers spawned from this are resource intensive.
1.  comment out all the monitors but one in dead_man_switch.sh
2.  build the image and name it appropriately for that specific check.
3.  build another one with a different one uncommented, name it appropriately, so on and so forth.
4.  alternatively just run the bash scripts on a live host? but defeating fault tolerance of a task scheduler.

STEPS FOR SOLO DEPLOYMENT:
1.  edit the variables within the scripts for your environment.
2.  test that it works by running dead_man_switch.sh loud/silent/talk/kill as well as rocketc||slack_alert.sh queued/running/failed/lost
3.  `docker build .`
4.  `docker tag "ID FROM ABOVE" "NEW NAME"`
5.  `docker run -it "NEW IMAGE NAME"`
6.  `docker ps #FIND CONTAINER`
7.  `docker exec -it "CONTAINER" bash`

STEPS FOR DEPLOYING ON THE HASHICORP STACK: (CONSUL/NOMAD):
1.  edit the variables within the scripts for your environment.
2.  test that it works by running dead_man_switch.sh loud/silent/talk/kill as well as rocketc||slack_alert.sh queued/running/failed/lost
3.  copy the below config into nomadsm.nomad (or whatever_name_you_wish.nomad/json/etc...)
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
        #image = "localhost:5000/nomad_s_monitor"
        network_mode = "host"
        port_map = {
        }
        #volumes = [ "" ]
      }
      env {
      }
      resources {
        cpu    = 32
        memory = 128
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
4.  `nomad plan nomadsm.nomad`
5.  make any adjustments to the plan as you see fit(i.e. task/group/resources/service changes).
6.  `nomad run nomadsm.nomad` <br>
<br>
Images in the img dir of screen captures.
