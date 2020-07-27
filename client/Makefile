APPNAME=ignite

SOURCE=Dockerfile
IMAGE=${APPNAME}/frontdev:latest
CONTAINER=front-dev

# build container
build: Dockerfile
	docker image build -f ${SOURCE} -t ${IMAGE} .

# create new container and login to the shell
shell:
	docker container run -it --rm -v ${PWD}/src:/work/src -v ${PWD}/bin:/work/bin ${IMAGE}

# clean up all stopped containers
clean:
	docker container prune

# delete all image
doomsday:
	docker image rm `docker image ls -q`


elm: src/Main.elm
	docker container run --rm -v ${PWD}/src:/work/src -v ${PWD}/bin:/work/bin ${IMAGE} elm make src/Main.elm --output=bin/main.js
	cp src/index.html bin/index.html

serve:
	docker container run --rm -p 8080:8080 -v ${PWD}/bin:/work ${IMAGE} http-server
