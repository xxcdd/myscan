FROM python:3.7.5
LABEL maintainer="github:xxcdd" \
    name="myscan" \
    description="myscan" \
    docker.run.cmd='docker run --rm -p 127.0.0.1:6379:6379 -p 127.0.0.1:8000:8000 myscan "python cli.py webscan --disable power --clean --process 5"'
ADD jdk-8u281-linux-x64.tar.gz /usr/local
ENV JAVA_HOME=/usr/local/jdk1.8.0_281
ENV CLASSPATH=$JAVA_HOME/bin
ENV PATH=.:$JAVA_HOME/bin:$PATH
COPY myscan /myscan
COPY requirements.txt /myscan
WORKDIR /myscan
RUN cat /etc/os-release && \
    sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org/debian-security|mirrors.ustc.edu.cn/debian-security|g' /etc/apt/sources.list && \
    apt-get update && \
    apt install -y redis-server && \
    pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple && \
    { \
        echo '#!/bin/bash'; \
        echo ''; \
        echo 'redis-server --daemonize yes --port 6379 --bind 0.0.0.0'; \
        echo 'nohup python -m http.server 8000 &'; \
        echo '$1'; \
    } >> run.sh && \
    chmod +x run.sh
ENTRYPOINT ["sh", "run.sh"]

EXPOSE 6379