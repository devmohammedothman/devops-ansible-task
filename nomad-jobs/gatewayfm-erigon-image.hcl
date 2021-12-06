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
  type = "service"

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
    }

    volume "erigon-volume" {
      type            = "csi"
      source          = "ebs-test1"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
      per_alloc       = true
      mount_options {
        fs_type     = "ext4"
      }
    }
    # The service block tells Nomad how to register this service
    # with Consul for service discovery and monitoring.
    service {
      # This tells Consul to monitor the service on the port
      # labelled "http". Since Nomad allocates high dynamic port
      # numbers, we use labels to refer to them.
      name = "erigon-service"
      port = "tcp_30303"

      // check {
      //   name     = "alive"
      //   type     = "tcp_30303"
      //   interval = "10s"
      //   timeout  = "2s"
      // }
    }

    # Create an individual task (unit of work). This particular
    # task utilizes a Docker container to front a web application.
    task "erigon-task" {
      # Specify the driver to be "docker". Nomad supports
      # multiple drivers.
      driver = "docker"

      # Configuration is specific to each driver.
      config {
        image = "thorax/erigon:latest"
        args = [
          "erigon" , "--chain=ropsten",
          "--metrics", "--metrics.addr=0.0.0.0",
          "--metrics.port=6060",
          "--private.api.addr=0.0.0.0:9090",
          "--pprof", "--pprof.addr=0.0.0.0","--pprof.port=6061"
        ]

        // env {
        //   MOUNT_PATH = "${NOMAD_ALLOC_DIR}/erigonData"
        // }

        volume_mount {
          volume      = "erigon-volume"
          destination = "/home/erigon/.local/share/erigon"
        }

        volumes = [
            # Use absolute paths to mount arbitrary paths on the host
            # ${XDG_DATA_HOME:-~/.local/share}/erigon:/home/erigon/.local/share/erigon
            "/erigonData:/home/erigon/.local/share/erigon"
          ]
        ports = ["http","tcp_30303","tcp_30304","udp_30303","udp_30304"]
      }

      csi_plugin {
        id        = "aws-ebs0"
        type      = "controller"
        mount_dir = "/erigonData"
      }
      # Specify the maximum resources required to run the task,
      # include CPU and memory.
      resources {
        cpu    = 500 # MHz
        memory = 256 # MB
      }
    }
  }

  group "prometheus-group"{
    network{
      port "http_9090" {
        static = "9090"
      }
    }

    volume "prometheus-volume" {
      type            = "csi"
      source          = "ebs-test1"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
      per_alloc       = true
      mount_options {
        fs_type     = "ext4"
      }
    }
    service {
      name = "prometheus-service"
      port = "http_9090"
      // check {
      //   name     = "alive"
      //   type     = "http_9090"
      //   interval = "10s"
      //   timeout  = "2s"
      // }
    }

    task "prometheus-task" {
      driver = "docker"

      config{
        image = "prom/prometheus:v2.30.2"
        ports = ["http_9090"]
        args = [
          "--log.level=warn" , "--config.file=/etc/prometheus/prometheus.yml",
          "--storage.tsdb.path=/prometheus", 
          "--web.console.libraries=/usr/share/prometheus/console_libraries",
          "--web.console.templates=/usr/share/prometheus/consoles"
        ]

        env {
            # this will be available as the MOUNT_PATH environment
            # variable in the task
            MOUNT_PATH = "${NOMAD_ALLOC_DIR}/erigonData"
          }

        volume_mount {
            volume      = "prometheus-volume"
            destination = "${NOMAD_ALLOC_DIR}/erigonData"
          }
        
        volumes = [
            # Use absolute paths to mount arbitrary paths on the host
            # ${ERIGON_PROMETHEUS_CONFIG:-./cmd/prometheus/prometheus.yml}:/etc/prometheus/prometheus.yml
            # ${XDG_DATA_HOME:-~/.local/share}/erigon-prometheus:/prometheus
            "/erigonData:/etc/prometheus/prometheus.yml",
            "/erigonData:/prometheus",
        ]
      }
      csi_plugin {
        id        = "aws-ebs0"
        type      = "controller"
        mount_dir = "/erigonData"
      }
      resources {
        cpu    = 500 # MHz
        memory = 256 # MB
      }
    }
  }
  
  group "grafana-group"{
    network{
      port "http_3000" {
        static = "3000"
      }
    }

    volume "grafana-volume" {
      type            = "csi"
      source          = "ebs-test1"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
      per_alloc       = true
      mount_options {
        fs_type     = "ext4"
      }
    }
    service {
      name = "grafana-service"
      port = "http_3000"
      // check {
      //   name     = "alive"
      //   type     = "http_3000"
      //   interval = "10s"
      //   timeout  = "2s"
      // }
    }

    task "grafana-task" {
      driver = "docker"

      config{
        image = "grafana/grafana:8.2.2"
        ports = ["http_3000"]
        args = [
            "--log.level=warn" , "--config.file=/etc/prometheus/prometheus.yml",
            "--storage.tsdb.path=/prometheus", 
            "--web.console.libraries=/usr/share/prometheus/console_libraries",
            "--web.console.templates=/usr/share/prometheus/consoles"
          ]
      
      env {
          # this will be available as the MOUNT_PATH environment
          # variable in the task
          MOUNT_PATH = "${NOMAD_ALLOC_DIR}/erigonData"
        }

      volume_mount {
        volume      = "grafana-volume"
        destination = "${NOMAD_ALLOC_DIR}/erigonData"
      }

      volumes = [
            # Use absolute paths to mount arbitrary paths on the host
            # ${ERIGON_GRAFANA_CONFIG:-./cmd/prometheus/grafana.ini}:/etc/grafana/grafana.ini
            # ./cmd/prometheus/datasources:/etc/grafana/provisioning/datasources
            # ./cmd/prometheus/dashboards:/etc/grafana/provisioning/dashboards
            # ${XDG_DATA_HOME:-~/.local/share}/erigon-grafana:/var/lib/grafana
            "/erigonData:/etc/grafana/grafana.ini",
            "/erigonData:/etc/grafana/provisioning/datasources",
            "/erigonData:/etc/grafana/provisioning/dashboards",
            "/erigonData:/var/lib/grafana"
        ]
      }
      csi_plugin {
        id        = "aws-ebs0"
        type      = "controller"
        mount_dir = "/erigonData"
      }
      resources {
        cpu    = 500 # MHz
        memory = 256 # MB
      }

    }
  }

  group "rpcdaemon-group"{
    network{
      port "http_8545" {
        static = "8545"
      }
    }

    volume "rpcdaemon-volume" {
      type            = "csi"
      source          = "ebs-test1"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
      per_alloc       = true
      mount_options {
        fs_type     = "ext4"
      }
    }
    service {
      name = "rpcdaemon-service"
      port = "http_8545"
      // check {
      //   name     = "alive"
      //   type     = "http_8545"
      //   interval = "10s"
      //   timeout  = "2s"
      // }
    }

    task "rpcdaemon-task" {
      driver = "docker"

      config{
        image = "thorax/erigon:latest"
        ports = ["http_8545"]
        args = [
          "rpcdaemon",
          "--datadir=/home/erigon/.local/share/erigon" , 
          "--private.api.addr=erigon:9090",
          "--http.addr=0.0.0.0", 
          "--http.vhosts=*",
          "--http.corsdomain=*",
          "--http.api=eth,debug,net",
          "--ws"
        ]
        
        env {
            # this will be available as the MOUNT_PATH environment
            # variable in the task
            MOUNT_PATH = "${NOMAD_ALLOC_DIR}/erigonData"
          }

       
        volume_mount {
            volume      = "rpcdaemon-volume"
            destination = "${NOMAD_ALLOC_DIR}/erigonData"
          }

        volumes = [
            # Use absolute paths to mount arbitrary paths on the host
            # {XDG_DATA_HOME:-~/.local/share}/erigon:/home/erigon/.local/share/erigon
            # ${XDG_DATA_HOME:-~/.local/share}/erigon-prometheus:/prometheus
            "/erigonData:/home/erigon/.local/share/erigon"
        ]
      }
      csi_plugin {
        id        = "aws-ebs0"
        type      = "controller"
        mount_dir = "/erigonData"
      }
      resources {
        cpu    = 500 # MHz
        memory = 256 # MB
      }
    }
  }
}
