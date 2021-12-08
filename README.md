<p align="center">
  <a href="" rel="noopener">
 <img width=200px height=200px src="https://i.imgur.com/6wj0hh6.jpg" alt="Project logo"></a>
</p>

<h3 align="center">Ansible Hands on</h3>

<div align="center">

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![GitHub Issues](https://img.shields.io/github/issues/kylelobo/The-Documentation-Compendium.svg)](https://github.com/kylelobo/The-Documentation-Compendium/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/kylelobo/The-Documentation-Compendium.svg)](https://github.com/kylelobo/The-Documentation-Compendium/pulls)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)

</div>

---

<p align="center"> This repo for practicing Ansible playbooks 
    <br> 
</p>

## 📝 Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Deployment](#nomad_Jobs)
- [Usage](#Steps)
- [Authors](#authors)
- [Acknowledgments](#acknowledgement)

## 🧐 About <a name = "about"></a>

I am providing here few Ansible playbooks which will be used to configure Ubuntu EC2 machine and provision required pakcages and tools 
Also another part is to install/configure Nomad as a workload orchestrator
Then having deployed erigon aks "Ethereum client" 

## 🏁 Getting Started <a name = "getting_started"></a>

Assumptions include:

 -- Ubuntu 20.04 LTS
 -- EC2 instance as a host
 -- Attached Volume
 -- Ansible installed on the control machine

## Project Structure and Ansible Playbooks & Example Outputs

![Alt text](erigon-project-directory-structure.jpg?raw=true "project")

### Mounted Volume Data

![Alt text](erigon-project-Volume-Mount.jpg?raw=true "project")


### Erigon Task resources

![Alt text](erigon-project-erigon-resources.jpg?raw=true "project")

### Nomad All Services

![Alt text](erigon-project-all-services.jpg?raw=true "project")

```
basic-utility this playbook will configre/install basic requirements
provision-node this playbook will install Docker and Nomda as a container orchestrator.
Manage-containers this playbook will create Nomad job which will deploy the "Ethereum client"
```

### Installing

You can Simply run all playbook using the main.yml 

```
ansible-playbook main.yml
```

Or you can specify some playbook to run

```
ansible-playbook playbooks/basic-utility.yml
ansible-playbook playbooks/provision-node.yml
ansible-playbook playbooks/manage-containers.yml
```

Also you can specify to run playbook with --tags option

```
ansible-playbook playbooks/basic-utility.yml --tags utils
ansible-playbook playbooks/provision-node.yml --tags docker
ansible-playbook playbooks/provision-node.yml --tags docker
```
.

## 🔧 Running nomad <a name = "nomad_Jobs"></a>



### To run nomad Job & Check nomad job status & logs

```
nomad run nomad-job.hcl
nomad job status JOBNAME
nomad alloc status ALLOCID
```


## 🎈 Steps <a name="Steps"></a>

 - Install basic Utilities
 - Provision Machine 
    * Mount Driver related tasks.
    * Update Host Name
    * Install & Configure Nomad 
    *  Enable Nomad Agent/Service on Systemd
    * Install Docker
 - Deploy Ethereum node as a container into Nomad with the following tasks
    * Configure Job
    * Configure erigon 
    * Configure Prometheus
    * Configure Grafana
    * Mount Docker Volumes

## 🚀 Deployment <a name = "deployment"></a>

This project assumes the Node machines will be AWS EC2 Ubuntu 20.4 based, with attached EBS Volume
Machine specs should be at least 4 GB RAM, 4 Core CPU

Deployment Easily managed with ansible and you can override vars.yml file for certain variables values.

## ⛏️ Built Using <a name = "built_using"></a>

- [Ansible](https://docs.ansible.com/ansible/latest/user_guide/intro_getting_started.html) - Ansible
- [nomad](https://learn.hashicorp.com/nomad) - Nomad

## ✍️ Authors <a name = "authors"></a>

- [@DEV.MOHAMMED.OTHMAN](https://github.com/devmohammedothman/) - Idea & Initial work


## 🎉 Acknowledgements <a name = "acknowledgement"></a>

- Inspiration
- References
  * https://github.com/ledgerwatch/erigon/blob/stable/docker-compose.yml

  * https://discuss.hashicorp.com/t/translating-docker-compose-yml-with-multiple-services-using-a-common-image-to-nomad-job/21071

  * https://docs.ansible.com/ansible/latest/collections/community/general/nomad_job_module.html#examples

  * https://www.nomadproject.io/docs/drivers/docker#init
  * https://www.shubhamdipt.com/blog/how-to-create-a-systemd-service-in-linux/

  * https://learn.hashicorp.com/tutorials/nomad/production-deployment-guide-vm-with-consul#configure-systemd

  * https://devopscube.com/mount-ebs-volume-ec2-instance/

  * https://learn.hashicorp.com/tutorials/nomad/get-started-ui?in=nomad/get-started

  * https://learn.hashicorp.com/tutorials/nomad/jobs-configuring?in=nomad/manage-jobs

  * https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#define-variables-in-inventory

  * https://prometheus.io/docs/prometheus/latest/getting_started/

  * https://pypi.org/project/python-nomad/

  * https://community.grafana.com/t/new-docker-install-with-persistent-storage-permission-problem/10896