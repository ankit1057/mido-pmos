FROM debian:bookworm-slim

LABEL maintainer="ankit1057 <https://github.com/ankit1057>"
LABEL description="pmbootstrap build environment for postmarketOS on Xiaomi Redmi Note 4 (mido)"

# ── System dependencies ─────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
    openssl \
    gnupg \
    wget \
    curl \
    sudo \
    parted \
    e2fsprogs \
    android-tools-fsutils \
    img2simg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ── pmbootstrap user ────────────────────────────────────────────────────────
RUN useradd -ms /bin/bash pmos && \
    echo "pmos ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER pmos
WORKDIR /home/pmos

# ── Install pmbootstrap ─────────────────────────────────────────────────────
RUN git clone --depth 1 https://gitlab.postmarketos.org/postmarketOS/pmbootstrap.git && \
    pip3 install --user --break-system-packages ./pmbootstrap

ENV PATH="/home/pmos/.local/bin:${PATH}"

# ── Pre-configure pmbootstrap for mido ─────────────────────────────────────
# The config below pre-seeds ~/.config/pmbootstrap.cfg so the container is
# ready to build without interactive `pmbootstrap init`.
RUN mkdir -p /home/pmos/.config
COPY --chown=pmos:pmos pmbootstrap.cfg /home/pmos/.config/pmbootstrap.cfg

VOLUME ["/home/pmos/.local/var/pmbootstrap"]

ENTRYPOINT ["/bin/bash", "-l"]
