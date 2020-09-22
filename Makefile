APPNAME=ignite

ifeq ($(shell uname),Linux)
	OS=$(shell uname)
else ifeq ($(shell uname),Darwin)
	OS=$(shell uname)
endif

SSH_DIR=~/.ssh
CONFIG_DIR=~/config

TRUE_INVENTORY=${CONFIG_DIR}/${APPNAME}
TRUE_ROOT_INVENTORY=${TRUE_INVENTORY}/root/inventory
TRUE_USER_INVENTORY=${TRUE_INVENTORY}/user/inventory
TRUE_MYSQL_INVENTORY=${TRUE_INVENTORY}/mysql/inventory

ANSIBLE_ROOT_INVENTORY=ansible/playbook/root/inventory
ANSIBLE_USER_INVENTORY=ansible/playbook/user/inventory
MYSQL_INVENTORY=mysql/inventory

APP_SOURCE=app/Dockerfile
APP_IMAGE=${APPNAME}/app:latest
APP_CONTAINER=app-server


# --- Entire Container Manipulation ---------------

.PHONY: stop
stop:
	docker container stop `docker container ls -q`

.PHONY: clean
clean:
	docker container prune

.PHONY: doomsday
doomsday:
	docker image rm -f `docker image ls -q`

# --- Container Manipulation ------------------

.PHONY: app_image
app_image:
	export ROOTDIR=`pwd` && docker-compose -f docker-compose/app_server.yml build

.PHONY: app_build
app_build:
	export ROOTDIR=`pwd` && docker-compose -f docker-compose/app_server.yml build --no-cache

.PHONY: app_shell
app_shell:
	export ROOTDIR=`pwd` && docker-compose -f docker-compose/app_server.yml run --rm app-server bash
	#docker container run -it --rm -p 8080:80 \
	#	-v ${PWD}:/go/src/github.com/ignite \
	#	--workdir /go/src/github.com/ignite/app \
	#	${APP_IMAGE}

# --- Check Service Configuration ---------------

.PHONY: local_config
local_config:
	export ROOTDIR=`pwd` && docker-compose -p local \
		-f docker-compose/reverse_proxy.yml \
		-f docker-compose/app_server.yml \
		-f docker-compose/maintenance.yml \
		-f docker-compose/env/local/reverse_proxy.yml \
		config
	
.PHONY: castor_config
castor_config:
	export ROOTDIR=`pwd` && docker-compose -p local \
		-f docker-compose/reverse_proxy.yml \
		-f docker-compose/app_server.yml \
		-f docker-compose/maintenance.yml \
		-f docker-compose/env/castor/reverse_proxy.yml \
		config

# --- Local Service Manipulation ---------------

.PHONY: serve
serve:
	export ROOTDIR=`pwd` && docker-compose \
		-f docker-compose/reverse_proxy.yml \
		-f docker-compose/maintenance.yml \
		-f docker-compose/app_server.yml \
		-f docker-compose/env/local/reverse_proxy.yml \
		up -d
	sleep 5
	docker-compose -f docker-compose/maintenance.yml down

.PHONY: stop_serve
stop_serve:
	export ROOTDIR=`pwd` && docker-compose \
		-f docker-compose/reverse_proxy.yml \
		-f docker-compose/maintenance.yml \
		-f docker-compose/app_server.yml \
		-f docker-compose/env/local/reverse_proxy.yml \
		down

# --- Remote Service Manipulation ---------------

.PHONY: deploy
deploy:
	export ROOTDIR=`pwd` && docker-compose \
		-f docker-compose/reverse_proxy.yml \
		-f docker-compose/maintenance.yml \
		-f docker-compose/app_server.yml \
		-f docker-compose/env/castor/reverse_proxy.yml
		up -d
	sleep 5
	docker-compose -f docker-compose/maintenance.yml down

.PHONY: stop_remote
stop_remote:
	export ROOTDIR=`pwd` && docker-compose \
		-f docker-compose/reverse_proxy.yml \
		-f docker-compose/maintenance.yml \
		-f docker-compose/app_server.yml \
		-f docker-compose/env/castor/reverse_proxy.yml
		down

.PHONY: start_maintenance
start_maintenance:
	docker-compose -f docker-compose/maintenance.yml up -d
	sleep 15
	docker-compose -f docker-compose/app_server.yml down

.PHONY: end_maintenance
end_maintenance:
	docker-compose -f docker-compose/app_server.yml up -d
	sleep 15
	docker-compose -f docker-compose/maintenance.yml down

# --- Let's Encrypt ---------------

.PHONY: newcert
newcert:
	docker exec -it reverse_proxy certbot certonly --nginx --agree-tos \
		-m youremail@email.com \
		-d example.com \
		-d ignite.example.com

.PHONY: recert
recert:
	docker exec -it reverse_proxy certbot renew --dry-run

# --- Utils ---------------

.PHONY: validate
.SILENT:
validate:
ifeq (${OS},Linux)
	echo "Linux OS recognized: success"
else ifeq (${OS},Darwin)
	echo "OSX recognized: success"
else
	echo "Unrecognized OS: failure"
endif

update_appname:	
ifdef OS
	export OS=${OS} \
	&& export APPNAME=${APPNAME} \
	&& ./script/update_appname.sh
else
	echo "Unrecognized OS: failure"
endif

.PHONY: true_inventory
.SILENT:
true_inventory:
	echo ${TRUE_INVENTORY}

copy_inventory:
	export TRUE_INVENTORY=${TRUE_INVENTORY} \
	&& ./script/copy_inventory.sh
