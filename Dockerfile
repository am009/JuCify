FROM ubuntu:18.04

# clean files in .gitignore before building image

# develop: docker run -it --name test_jucify -v C:\JuCify\:/root/Jucify ubuntu:22.04
# headless jdk saves 300mb space
# "build-essential python3.7-dev graphviz libgraphviz-dev" is required for pygraphviz
SHELL ["/bin/bash", "-c"]

RUN sed -i "s/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list \
 && sed -i "s/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list \
 && apt update && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends git wget sudo software-properties-common nano maven openjdk-8-jdk-headless python3.7 python3.7-venv python3-pip python3.7-dev build-essential graphviz libgraphviz-dev unzip \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /root

# Python env
RUN python3.7 -m venv jucify_venv \
 && echo source /root/jucify_venv/bin/activate >> /root/.bashrc \
 && source /root/jucify_venv/bin/activate \
 && python3.7 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pip \
 && python3.7 -m pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple \
 && python3.7 -m pip install wheel angr==8.20.7.6 androguard==3.3.5 pygraphviz==1.7 protobuf==3.20.1

COPY [".", "/root/JuCify/"]

# build jucify jar
WORKDIR /root/JuCify
RUN /root/JuCify/build.sh

# /root/JuCify/runTool.sh
ENTRYPOINT ["/bin/bash", "/root/JuCify/runTool.sh"]
CMD ["-p", "/platforms", "-f", "/root/apps/app.apk", "-t", "-c"]
