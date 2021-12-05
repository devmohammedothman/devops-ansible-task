# This declares a job named "docs". There can be exactly one
# job declaration per job file.
job "gatewayfm-erigon-job" {
  # Specify this job should run in the region named "us". Regions
  # are defined by the Nomad servers' configuration.
  # region = "us"

  # Spread the tasks in this job between us-west-1 and us-east-1.
  datacenters = ["dc1"]

  # Run this job as a "service" type. Each job type has different
  # properties. See the documentation below for more examples.
  type = "service"

  # Specify this job to have rolling updates, two-at-a-time, with
  # 30 second intervals.
  update {
    stagger      = "30s"
    max_parallel = 2
  }


  # A group defines a series of tasks that should be co-located
  # on the same client (host). All tasks within a group will be
  # placed on the same host.
  group "gatewayfm-erigon-group" {
    # Specify the number of these tasks we want.
    count = 1

    network {
      # This requests a dynamic port named "http". This will
      # be something like "46283", but we refer to it via the
      # TCP # to = 65535
      # label "http".
      port "http" {
        to = 8080
      }

      port "tcp_30303" {
        to = 30303
      }

      port "tcp_30304" {
        to = 30304
      }

      port "udp_30303" {
        to = 30303
      }

      port "udp_30304" {
        to = 30304
      }
    }

    # The service block tells Nomad how to register this service
    # with Consul for service discovery and monitoring.
    service {
      # This tells Consul to monitor the service on the port
      # labelled "http". Since Nomad allocates high dynamic port
      # numbers, we use labels to refer to them.
      # port = "http"

      # check {
      #   name     = "alive"
      #   type     = "tcp"
      #   interval = "25s"
      #   timeout  = "20s"
      # }
    }

    # Create an individual task (unit of work). This particular
    # task utilizes a Docker container to front a web application.
    task "gatewayfm-erigon-task" {
      # Specify the driver to be "docker". Nomad supports
      # multiple drivers.
      driver = "docker"

      # Configuration is specific to each driver.
      config {
        image = "thorax/erigon"
        args = [
          "--metrics", "--metrics.addr=0.0.0.0",
          "--metrics.port=6060",
          "--private.api.addr=0.0.0.0:9090",
          "--pprof", "--pprof.addr=0.0.0.0","--pprof.port=6061"
        ]
        ports = ["http","tcp_30303","tcp_30304","udp_30303","udp_30304"]
      }
      # Specify the maximum resources required to run the task,
      # include CPU and memory.
      resources {
        cpu    = 500 # MHz
        memory = 256 # MB
      }
    }
  }
}
