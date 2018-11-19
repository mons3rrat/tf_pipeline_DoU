FROM tianon/github-hub

ENV TERRAFORM_VERSION=0.11.10
ENV DOCKER_VERSION=18.06.1

RUN apt-get update && apt-get install -y curl unzip \
     && curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
     && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin \
     && rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
     && cd /tmp \
     && wget "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}-ce.tgz" \
     && tar -xzvf docker-* \
     && cd docker \
     && mv docker /usr/local/bin \
     && rm -rf /tmp/*