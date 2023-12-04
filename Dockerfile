FROM arm64v8/debian:bookworm-slim

COPY scripts /opt/scripts

RUN apt-get update && apt-get upgrade -y \
    # Install prerequisites
    && apt-get install -y \
    curl \
    gosu \
    jq \
    libicu-dev \
    nano \
    # Prepare .docker_config
    && mkdir /opt/.docker_config \
    && echo "true" > /opt/.docker_config/.first_run \
    # Create runner user
    && useradd -ms /bin/bash runner \
    && adduser runner runner \
    # Set permissions ans ownership
    && chown -R runner:runner /opt/scripts \
    && chmod 755 /opt/scripts/*.sh 

USER runner
WORKDIR /home/runner

ENTRYPOINT ["/bin/bash", "-c", "/opt/scripts/startup.sh"]
