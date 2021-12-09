# This declares a job named "docs". There can be exactly one
# job declaration per job file.
job "gatewayfm_job" {
  # Specify this job should run in the region named "us". Regions
  # are defined by the Nomad servers' configuration.
  # region = "us"

  # Spread the tasks in this job between us-west-1 and us-east-1.
  datacenters = ["dc1"]

  # Run this job as a "service" type. Each job type has different
  # properties. See the documentation below for more examples.
  // type = "service"

  # Specify this job to have rolling updates, two-at-a-time, with
  # 30 second intervals.
  update {
    stagger      = "30s"
    max_parallel = 2
  }

  constraint {
    attribute = "${attr.os.name}"
    value     = "ubuntu"
  }

  # A group defines a series of tasks that should be co-located
  # on the same client (host). All tasks within a group will be
  # placed on the same host.
  group "erigon-group" {
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

      port "http_8545" {
        static = "8545"
      }

    }

    # Create an individual task (unit of work). This particular
    # task utilizes a Docker container to front a web application.
    task "erigon-task" {
      # Specify the driver to be "docker". Nomad supports
      # multiple drivers.
      driver = "docker"
      user   = "erigon"
      # Configuration is specific to each driver.
      config {
        image      = "thorax/erigon:latest"
        privileged = true
        args = [
          "erigon", "--chain=ropsten",
          "--metrics", "--metrics.addr=0.0.0.0",
          "--metrics.port=6060",
          "--private.api.addr=0.0.0.0:9090",
          "--pprof", "--pprof.addr=0.0.0.0", "--pprof.port=6061"
        ]
        volumes = [
            "/erigonVolumeData/erigon_data/:/home/erigon/.local/share/erigon"
        ]
        ports = ["http", "tcp_30303", "tcp_30304", "udp_30303", "udp_30304"]
      }

      # Specify the maximum resources required to run the task,
      # include CPU and memory.
      resources {
        cpu    = 2000 # MHz
        memory = 4000 # MB
      }
    }

    task "rpcdaemon-task" {
      driver = "docker"
      user   = "erigon"
      config {
        image      = "thorax/erigon:latest"
        ports      = ["http_8545"]
        privileged = true
        args = [
          "rpcdaemon",
          "--private.api.addr=localhost:9090",
          "--http.addr=0.0.0.0",
          "--http.vhosts=*",
          "--http.corsdomain=*",
          "--http.api=eth,debug,net",
          "--ws"
        ]
        volumes = [
            "/erigonVolumeData/erigon_data:/home/erigon/.local/share/erigon"
        ]
      }
      resources {
        cpu    = 500  # MHz
        memory = 1000 # MB
      }
    }


  }

  ############################################################ Monitoring Group##############################################

  group "prometheus-group" {
    # Specify the number of these tasks we want.
    count = 1

    network {

      port "http_9090" {
        static = "9090"
      }
    }
    task "prometheus-task" {
      driver = "docker"
      config {
        image      = "prom/prometheus:v2.30.2"
        ports      = ["http_9090"]
        privileged = true
        args = [
          "--log.level=warn", "--config.file=/etc/prometheus/prometheus.yml",
          "--storage.tsdb.path=/prometheus",
          "--web.console.libraries=/usr/share/prometheus/console_libraries",
          "--web.console.templates=/usr/share/prometheus/consoles"
        ]
        mount {
          type = "volume"
          target = "/prometheus"
          source = "erigonVolumeData"
          readonly = false
          bind_options {
            propagation = "rshared"
          }
        }
      }
      resources {
        cpu    = 500  # MHz
        memory = 500 # MB
      }
    }
  }

  group "grafana-group" {
    # Specify the number of these tasks we want.
    count = 1

    network {
      port "http_3000" {
        static = "3000"
      }
    }

    task "grafana-task" {
      driver = "docker"
      user   = 472
      config {
        image      = "grafana/grafana:8.2.2"
        ports      = ["http_3000"]
        privileged = true
        volumes = [
          # "/erigonVolumeData/grafana_data/grafana.ini:/etc/grafana/grafana.ini",
          # "/erigonVolumeData/grafana_data:/var/lib/grafana",
          "/erigonVolumeData/grafana_data:/etc/grafana/provisioning/dashboards",
          "/erigonVolumeData/grafana_data:/etc/grafana/provisioning/datasources"
        ]
       
      }
      resources {
        cpu    = 500  # MHz
        memory = 500 # MB
      }
    }
  }
}
