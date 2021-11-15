FROM ubuntu:18.04
ARG TERRAFORM_VERSION=1.0.5
ARG K8S_VERSION=v1.19.2
ARG HELM_VERSION=v3.2.4
ARG HELM_FILENAME=helm-${HELM_VERSION}-linux-amd64.tar.gz
ARG KUBESPRAY_VERSION=2.14.2
ARG NEWMAN_VERSION=5.0.0

# Update apt and Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    dnsutils \
    git \
    jq \
    libssl-dev \
    openvpn \
    python3 \
    python3-pip \
    screen \
    vim \
    wget \
    zip \
    mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Install tools and configure the environment
RUN wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -O /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin/ \
    && rm /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN wget -q https://github.com/kubernetes-sigs/kubespray/archive/v${KUBESPRAY_VERSION}.tar.gz \
    && tar zxvf v${KUBESPRAY_VERSION}.tar.gz \
    && ln -sf kubespray-${KUBESPRAY_VERSION} kubespray \
    && rm v${KUBESPRAY_VERSION}.tar.gz

RUN wget -q https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

RUN wget -q -O- https://get.helm.sh/${HELM_FILENAME} | tar xz && \
    mv linux-amd64/helm /bin/helm && \
    rm -rf linux-amd64

#install newman
RUN curl -sL https://deb.nodesource.com/setup_15.x | bash - && apt-get install -y nodejs && npm install -g newman@${NEWMAN_VERSION} && npm install -g newman-reporter-html

RUN cd kubespray && python3 -m pip install -r requirements.txt
# COPY kubespray-requirements.txt requirements.txt
# RUN python3 -m pip install -r requirements.txt


RUN pip3 install --upgrade pip \
    && mkdir /workdir && cd /workdir \
    && mkdir keys \
    && python3 -m pip install netaddr awscli

RUN pip3 install "openshift>=0.6" "setuptools>=40.3.0" \
     && ansible-galaxy collection install community.kubernetes

RUN pip3 install "openshift>=0.6" "setuptools>=40.3.0"

COPY . iac-run-dir
