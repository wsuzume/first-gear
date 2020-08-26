APPNAME=ignite

SOURCE=Dockerfile
IMAGE=${APPNAME}/api:latest
CONTAINER=api-server

image: Dockerfile
	docker image build -f ${SOURCE} -t ${IMAGE} .

shell:
	docker container run -it --rm -p 8080:8080 -v ${PWD}:/go/src/work ${IMAGE}
