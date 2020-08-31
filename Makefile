APPNAME=ignite

APP_SOURCE=app/Dockerfile
APP_IMAGE=${APPNAME}/app:latest
APP_CONTAINER=app-server
APP_HOSTNAME=ignite

.PHONY: stop
stop:
	docker container stop `docker container ls -q`

.PHONY: clean
clean:
	docker container prune

.PHONY: app_image
app_image:
	docker image build -f ${APP_SOURCE} -t ${APP_IMAGE} ./app

.PHONY: app_shell
app_shell:
	docker container run -it --rm -p 8080:80 \
		-v ${PWD}:/go/src/github.com/ignite \
		${APP_IMAGE}

.PHONY: serve
serve:
	docker container create -it -p 8080:80 --hostname ${APP_HOSTNAME} --name ${APP_CONTAINER} \
		-v ${PWD}:/go/src/github.com/ignite \
		${APP_IMAGE}
	docker network connect appfront ${APP_CONTAINER}
	docker network connect appback ${APP_CONTAINER}
	docker container start ${APP_CONTAINER}
	docker container exec -it ${APP_CONTAINER} go run app/main.go

.PHONY: init
init:
	docker-compose -f docker-compose.yml up

.PHONY: deploy
deploy:
	docker-compose -f docker-compose-deploy.yml up

.PHONY: start_maintenance
start_maintenance:
	docker-compose -f docker-compose-maintenance.yml up
	sleep 15
	docker-compose -f docker-compose-deploy.yml down

.PHONY: end_maintenance
end_maintenance:
	docker-compose -f docker-compose-deploy.yml up
	sleep 15
	docker-compose -f docker-compose-maintenance.yml down
