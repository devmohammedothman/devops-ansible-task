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
- [Usage](#usage)
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

### Ansible Playbooks

What things you need to install the software and how to install them.

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


## 🎈 Usage <a name="usage"></a>

Add notes about how to use the system.

## 🚀 Deployment <a name = "deployment"></a>

Add additional notes about how to deploy this on a live system.

## ⛏️ Built Using <a name = "built_using"></a>

- [Ansible](https://docs.ansible.com/ansible/latest/user_guide/intro_getting_started.html) - Ansible
- [nomad](https://learn.hashicorp.com/nomad) - Nomad

## ✍️ Authors <a name = "authors"></a>

- [@DEV.MOHAMMED.OTHMAN](https://github.com/devmohammedothman/) - Idea & Initial work


## 🎉 Acknowledgements <a name = "acknowledgement"></a>

- Inspiration
- References
