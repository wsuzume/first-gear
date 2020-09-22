APPNAME=ignite

.PHONY: root
root:
	ansible-playbook -i root/inventory/server root/playbook.yml

.PHONY: docker
docker:
	ansible-playbook -i user/inventory/server user/0010_docker_setup.yml -u castor --private-key="~/.ssh/id_common"

.PHONY: clone
clone:
	ansible-playbook -i user/inventory/server user/0020_clone_ignite.yml -u castor --private-key="~/.ssh/id_common"

.PHONY: deploy
deploy:
	ansible-playbook -i user/inventory/server user/0030_deploy_ignite.yml \
		-u castor --private-key="~/.ssh/id_common"
