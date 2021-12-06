job "defectdojo" {
    datacenters = ["wdc"]
    type = "service"

    group "nginx" {
        network {
            port "nginx" {
                static = "8080"
            }
        }

        service {
            name = "nginx"
            port = "nginx"

            check {
                type = "tcp"
                port = "nginx"
                interval = "10s"
                timeout = "2s"
            }
        }

        task "nginx" {
            driver = "docker"
            config {
                image = "defectdojo/defectdojo-nginx:latest"
                ports = ["nginx"]
            }
            env {
                NGINX_METRICS_ENABLED="false"
            }
        }
    }

    group "uwsgi" {
        # network {
        #     port "uwsgi" {
        #         static = "8443"
        #     }
        # }

        # service {
        #     name = "uwsgi"
        #     port = "uwsgi"

        #     check {
        #         type = "tcp"
        #         port = "uwsgi"
        #         interval = "10s"
        #         timeout = "2s"
        #     }
        # }

        task "initializer" {
            driver = "docker"

             lifecycle {
                hook = "prestart"
                sidecar = false
            }

            config {
                image = "defectdojo/defectdojo-django:latest"
                # ports = ["uwsgi"]
                entrypoint = ["/wait-for-it.sh", "mysql:3306", "--", "/entrypoint-initializer.sh"]
                mounts = [
                    {
                      type = "bind"
                      target = "/app/docker/extra_settings"
                      source = "./docker/extra_settings"
                    }
                ]
            }

            resources {
                cpu    = 200
                memory = 128
            }

            # service {
            #     name = "initializer"
            # }

            env {
                DD_DATABASE_URL="mysql://defectdojo:defectdojo@mysql.service.consul:3308/defectdojo"
                DD_ADMIN_USER="admin"
                DD_ADMIN_MAIL="first.last@company.com"
                DD_ADMIN_FIRST_NAME="Admin"
                DD_ADMIN_LAST_NAME="User"
                DD_INITIALIZE="true"
                DD_SECRET_KEY="hhZCp@D28z!n@NED*yB!ROMt+WzsY*iq}"
                DD_CREDENTIAL_AES_256_KEY="&91a*agLqesc*0DJ+2*bAbsUZfR*4nLw"
            }
        }

        task  "uwsgi" {
            driver = "docker"
            config {
                image = "defectdojo/defectdojo-django:latest"
                # ports = ["uwsgi"]
                entrypoint = ["/wait-for-it.sh", "mysql:3306", "-t", "30", "--", "/entrypoint-uwsgi.sh"]
                mounts = [
                    {
                        type = "bind"
                        target = "/app/docker/extra_settings"
                        source = "./docker/extra_settings"

                    }
                ]

            }

            resources {
                cpu    = 200
                memory = 128
            }

            # service {
            #     name = "uwsgi"
            # }

            env {
                DD_DEBUG="false"
                DD_DJANGO_METRICS_ENABLED="false"
                DD_ALLOWED_HOSTS="*"
                DD_DATABASE_URL="mysql://defectdojo:defectdojo@mysql.service.consul:3308/defectdojo"
                DD_CELERY_BROKER_USER="guest"
                DD_CELERY_BROKER_PASSWORD="guest"
                DD_SECRET_KEY="hhZCp@D28z!n@NED*yB!ROMt+WzsY*iq"
                DD_CREDENTIAL_AES_256_KEY="&91a*agLqesc*0DJ+2*bAbsUZfR*4nLw"
            }
        }

    }

    group "celeryworker" {
        task "celeryworker" {
            driver = "docker"

            config {
                image = "defectdojo/defectdojo-django:latest"
                entrypoint = ["/wait-for-it.sh", "mysql:3306", "-t", "30", "--", "/entrypoint-celery-worker.sh"]
                mounts = [
                    {
                    type = "bind"
                    target = "/app/docker/extra_settings"
                    source = "./docker/extra_settings"
                    }
                ]
            }

            resources {
                cpu    = 200
                memory = 128
            }

            # service {
            #     name = "celeryworker"
            # }

            env {
                DD_DATABASE_URL="mysql://defectdojo:defectdojo@mysql.service.consul:3308/defectdojo"
                DD_CELERY_BROKER_USER="guest"
                DD_CELERY_BROKER_PASSWORD="guest"
                DD_SECRET_KEY="hhZCp@D28z!n@NED*yB!ROMt+WzsY*iq"
                DD_CREDENTIAL_AES_256_KEY="&91a*agLqesc*0DJ+2*bAbsUZfR*4nLw"
            }
        }
    }

    group "celerybeat" {
        task "celerybeat" {
            driver = "docker"
            config {
                image = "defectdojo/defectdojo-django:latest"
                entrypoint = ["/wait-for-it.sh", "mysql:3306", "-t", "30", "--", "/entrypoint-celery-beat.sh"]
                mounts = [
                    {
                        type = "bind"
                        target = "/app/docker/extra_settings"
                        source = "./docker/extra_settings"

                    }
                ]

            }

            resources {
                cpu    = 200
                memory = 128
            }

            # service {
            #     name = "celerybeat"
            # }

            env {
                DD_DATABASE_URL="mysql://defectdojo:defectdojo@mysql.service.consul:3308/defectdojo"
                DD_CELERY_BROKER_USER="guest"
                DD_CELERY_BROKER_PASSWORD="guest"
                DD_SECRET_KEY="hhZCp@D28z!n@NED*yB!ROMt+WzsY*iq"
                DD_CREDENTIAL_AES_256_KEY="&91a*agLqesc*0DJ+2*bAbsUZfR*4nLw"
            }

        }
    }
}