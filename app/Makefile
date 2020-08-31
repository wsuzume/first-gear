APPNAME=ignite

SOURCE=Dockerfile
IMAGE=${APPNAME}/app:latest
CONTAINER=app-server

image: Dockerfile
	docker image build -f ${SOURCE} -t ${IMAGE} .

shell:
	docker container run -it --rm -p 8080:80 -v ${PWD}:/go/src/work ${IMAGE}
