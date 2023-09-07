## Create RH Device Edge ISO Builder and Server using Ansible infra.osbuild collection

[OSBuild](https://www.osbuild.org/guides/introduction.html) is comprised of many individual projects
that work together to provide a wide range of features to build and assemble OS artifacts.
The GUI for OSBuild is known as `Image Builder` and provides access to the osbuild machinery. 

This document describes how to create a RH Device Edge ISO builder and server,
to enable over the air updates for your RH Device Edge machines.
The Ansible collection [infra.osbuild](https://github.com/redhat-cop/infra.osbuild) will be used. 

### Step 0: Launch a RHEL 9 system to use an an Edge ISO Builder

This assumes you have a Red Hat customer account.
With [RH ImageBuilder](https://console.redhat.com/insights/image-builder)
you can create RHEL 9.2 (.iso) images for Bare Metal installs
or various cloud vendors. For this, I created an AWS RHEL 9.2 AMI. This image will be associated with the
Amazon account you provide to Image Builder. I then went to AWS console and launched a `RHEL 9.2 t3.xlarge`
instance using this AMI, although there is also an option to launch this AMI directly from the
RH Hybrid Cloud Console Image Builder.

*The rest of this document assumes you have a `RHEL 9.2` machine running somewhere and you can SSH into this machine.*

### Add required files to builder VM

This repository has the files necessary to launch
[infra.osbuild roles](https://github.com/redhat-cop/infra.osbuild).

SSH into the RHEL builder VM.
Place these files on the system:

1. [inventory-local](./inventory-local) at ~/inventory
2. [./vars-example.yml](./vars-example.yml) at ~vars.yml
3. [./osbuild_builder.yml](./osbuild_builder.yml) at ~osbuild_builder.yml


Now run the playbook. I've included the commands to install ansible and the collection, if necessary.
This playbook will include 2 composes. First an edge-commit compose and then,
an installer image compose. This can take 20-40 minutes depending on the system.

```bash
sudo dnf install -y ansible
ansible-galaxy collection install infra.osbuild

ansible-playbook -i inventory-local osbuild_builder.yml -e builder_compose_type=edge-installer
```

#### Download ISO served from RHEL VM to local system, boot edge device

If all goes well, you should now have a `~/rhde_edge-installer.iso` at `http://<VM-ip-address>/rhde/images`.

You can write this iso to a usb drive to boot your physical edge device or use it to create a virtual machine.
If you wish to create a virtual machine with a local hypervisor
[watch this brief tutorial](https://youtu.be/1gTEpBuZV4o).
With the example kickstart file from this repository, a user is created in the VM 
`username: redhat, password: redhat`. 

### Serve RH Device Edge update commits and update edge machine

Your edge device should have a remote configured for the RHEL builder VM. Confirm this with:

```bash
cat /etc/ostree/remotes.d/rhel.conf

[remote "edge"]
url=http://<VM-ip-address>/rhde/repo/
gpg-verify=false
```

