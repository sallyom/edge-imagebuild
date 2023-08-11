## Create RH Device Edge ISO Builder and Server using Ansible infra.osbuild collection

[OSBuild](https://www.osbuild.org/guides/introduction.html) is comprised of many individual projects which work together
to provide a wide range of features to build and assemble OS artifacts.
The GUI for OSBuild is known as `Image Builder` and provides access to the osbuild machinery. 

This document describes how to create a RH Device Edge ISO builder and server, to enable over the air updates for your
RH Device Edge machines. The Ansible collection [infra.osbuild](https://github.com/redhat-cop/infra.osbuild) will be used as well as [Red Hat Ansible Automation Platform](https://docs.ansible.com/platform.html). 

### Step 00: You have access to Ansible Automation Platform 

For this example, AAP is running in OpenShift namespace `aap`, and an `ansible automation controller`
is deployed with the following:

```bash
oc apply -f aap-resources/automationcontroller-edge-osbuild.yaml 
```
You may need to access the AAP console to activate your RH subscription.

### Step 0: Launch a RHEL 9 system to use an an Edge ISO Builder

This assumes you have a Red Hat customer account.
With [RH ImageBuilder](https://console.redhat.com/insights/image-builder) you can create RHEL 9.2 (.iso) images for Bare Metal installs
or various cloud vendors. For this, I created an AWS RHEL 9.2 AMI. This image will be associated with the Amazon account you provide
to Image Builder. I then went to AWS console and launched a `RHEL 9.2 t3.xlarge` instance using this AMI, although there is also an
option to launch this AMI directly from the RH Hybrid Cloud Console Image Builder.

*The rest of this document assumes you have a `RHEL 9.2` machine running somewhere and you can SSH into this machine.*

### Create or modify a git repository with requirements & playbooks

This repository has the files necessary to launch [infra.osbuild roles](https://github.com/redhat-cop/infra.osbuild).
You may clone this or place these files in any git repository:

1. [./collections/requirements.yml](./collections/requirements.yml)
2. [./playbooks/osbuild_setup_server.yml](./playbooks/osbuild_setup_server.yml)
3. [./playbooks/osbuild_builder.yml](./playbooks/osbuild_builder.yml)
4. [inventory](./inventory)
5. [./vars-example.yml](./vars-example.yml)

### Configure Ansible Automation Controller

These instructions reference an AAP console with an automation controller created from
[aap-resources/automationcontroller-edge-osbuild.yaml](./aap-resources/automationcontroller-edge-osbuild.yaml)

#### Configure a Project

From the left, choose `Projects` then `Add` to create a new project. You'll need to fill in the following fields:

- Name (ex: edge-osbuilder)
- Execution Environment (choose 'Default execution environment')
- Source Control Type (dropdown -> Git)
    - Type Details (git URL, Branch/Tag/Commit)

Then, `Save`.

#### Configure an Inventory

From the left, choose `Inventories` then `Add->Add Inventory` to create a new inventory. You'll need to fill in the following fields:

- Name (ex: rhel9) 
- Variables (ex: below)

```
---
ansible_user: ec2-user
become: true
```

Then, `Save`.

#### Configure a Host

From the left, choose `Hosts` then `Add` to create a new host. You'll need to fill in the following fields:

- Name (ex: 54.162.54.33, ex: myhost.example.com)
- Inventory (choose the Inventory you created above)

Then, `Save`.

#### Configure a Template (job template)

[script to debug weldr proxy calls](https://github.com/mechpen/sockdump/blob/master/sockdump.py)

From the left, choose `Templates` then `Add` to create a new template. You will create a new template for every playbook you run.
You'll need to fill in the following fields:

**--TODO--FINISH**






#### SCP ISO from VM to local system, boot edge device
If all goes well, you should now have a `~/rhde-ztp.iso` 

Here's the final command to copy this over to your local system.

```bash
scp -i ~/.ssh/your.pem build-vm-user@build-vm-ipaddress:/home/your-build-machine-user/generate-iso/rhde-ztp.iso ~/Downloads

ls ~/Downloads/rhde-ztp.iso
-rw-r--r--. 1 somalley somalley 2314207232 Jun 13 11:46 /home/somalley/Downloads/rhde-ztp.iso
```

You can write this iso to a usb drive to boot your physical edge device or use it to create a virtual machine.
If you wish to create a virtual machine with a local hypervisor [watch this brief tutorial](https://youtu.be/1gTEpBuZV4o).
With the example kickstart file from this repository, a user is created in the VM `username: redhat, password: redhat`. 

### Serve RH Device Edge update commits and update edge machine

To point your edge devices to the builder, you can edit the remotes configuration file at `/etc/ostree/remotes.d/edge.conf`

```bash
cat /etc/ostree/remotes.d/rhel.conf

[remote "rhel"]
url=file:///run/install/repo/ostree/repo
gpg-verify=false

[remote "edge"]
gpg-verify=false
url=http://ip-address-of-build-machine:8000/repo
```

Whenever it is necessary to update your edge devices, you can point them to your Device Edge builder where you can serve ostree commits by
following [this workflow](./rpm-ostree-update/update.md).

