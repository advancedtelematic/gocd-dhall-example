DOCKER_RUN := \
	docker run -i --rm -v ${CURDIR}:/data --entrypoint=dhall-to-yaml advancedtelematic/dhall-json --key mk --value mv --omitNull --explain

print-yaml:
	cat ./pipelines.dhall | $(DOCKER_RUN) | tr -d '\r'

generate-yaml:
	cat ./pipelines.dhall | $(DOCKER_RUN) | tr -d '\r' > pipelines.gocd.yaml

docker-run:
	docker run -it --rm -v ${CURDIR}:/data advancedtelematic/dhall-json bash

run-gocd-server:
	# https://github.com/tomzo/gocd-yaml-config-plugin#setup
	docker run --detach --name=gocd --link gitlab:gitlab -p8153:8153 -p8154:8154 advancedtelematic/gocd-server:v18.9.0

run-gocd-agent:
	docker run \
		--detach \
		--name gocd-agent \
		-it \
		--link gitlab:gitlab \
		-e GO_SERVER_URL=https://$(shell docker inspect --format='{{(index (index .NetworkSettings.IPAddress))}}' gocd):8154/go \
		gocd/gocd-agent-ubuntu-16.04:v18.9.0

run-gitlab-locally:
	# https://developer.ibm.com/code/2017/07/13/step-step-guide-running-gitlab-ce-docker/
	docker run --detach --name gitlab \
	--hostname gitlab.example.com \
	--publish 30080:30080 \
         --publish 30022:22 \
	--env GITLAB_OMNIBUS_CONFIG="external_url 'http://gitlab.example.com:30080'; gitlab_rails['gitlab_shell_ssh_port']=30022;" \
	gitlab/gitlab-ce:9.1.0-ce.0
