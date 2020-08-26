# Ignite
The SPA template, includes

* Ansible: for VPS setup script
* Nginx: for Reverse Proxy, SSL offloading
* Certbot: for Automatic SSL certificate update
* Elm: for front-end framework
* golang/gin: for back-end framework
* MySQL: for RDB
* Redis: for KVS

## Tested Environment

* VPS
    * Ubuntu 18.04 LTS

## Usage
### Build and Enter Ansible Client

```
$ cd ansible

# build image
$ make image

# create and enter the container
$ make shell
```

### Setup Server
After `$ make shell`, run following command in the ansible client container.

```
$ make root
$ make user
```
