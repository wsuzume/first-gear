FROM ubuntu:18.04

RUN apt-get update \
    && apt-get install -y vim curl git python3 python3-pip

WORKDIR /playbook

# -------------

# install ansible
RUN pip3 install ansible
# need for ansible first login to remote server
RUN apt-get install sshpass

