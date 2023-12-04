FROM arm64v8/debian:bookworm-slim

COPY scripts /opt/scripts

RUN apt-get update && apt-get upgrade -y \
    # Install prerequisites
    && apt-get install --no-install-recommends -y \
    bc \
    ca-certificates \
    coreutils \
    curl \
    debootstrap \
    dosfstools \
    file \
    git \
    gpg \
    grep \
    sudo \
    jq \
    kpartx \
    kmod \
    libarchive-tools \
    libcap2-bin \
    libicu-dev \
    nano \
    parted \
    pigz \
    qemu-user-static \
    qemu-utils \
    quilt \
    rsync \
    xxd \
    xz-utils \
    zerofree \
    zip \
    # Prepare .docker_config
    && mkdir /opt/.docker_config \
    && echo "true" > /opt/.docker_config/.first_run \
    # Create runner user
    && useradd -ms /bin/bash runner \
    && adduser runner runner \
    && echo runner:Start123!. | chpasswd \
    && usermod -aG sudo runner \
    # Set permissions and ownership
    && chown -R runner:runner /opt/scripts \
    && chown -R runner:runner /opt/.docker_config \
    && chmod 755 /opt/scripts/*.sh
    # Clean up installation cache
    #&& apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    #&& apt-get autoclean -y \
    #&& apt-get autoremove \
    #&& apt-get clean \
    #&& rm -rf /tmp/* /var/tmp/* /root/.cache/* /root/.npm/* /var/lib/apt/lists/*

USER runner
WORKDIR /home/runner

ENTRYPOINT ["/bin/bash", "-c", "/opt/scripts/startup.sh"]
