FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# --- System packages (Vivado + GUI + build essentials) ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo wget curl ca-certificates git xz-utils bzip2 locales tzdata \
    openssh-server xauth x11-apps \
    libglib2.0-0 libdbus-1-3 \
    libxkbcommon-x11-0 libxcb-cursor0 libxcb-icccm4 libxcb-image0 \
    libxcb-keysyms1 libxcb-render-util0 libxcb-xinerama0 \
    libgl1 libegl1 libxrandr2 libxrender1 libxinerama1 \
    libfontconfig1 libfreetype6 libxi6 libtinfo6 \
    qt6-base-dev qt6-base-dev-tools libqt6gui6 libqt6core6 libqt6widgets6 \
    build-essential libc6-dev gcc-multilib g++-multilib \
    libpthread-stubs0-dev graphviz \
 && rm -rf /var/lib/apt/lists/*

# --- Vivado compatibility symlinks ---
RUN ln -sf /usr/lib/x86_64-linux-gnu/libtinfo.so.6 /usr/lib/x86_64-linux-gnu/libtinfo.so.5 \
 && ln -sf /usr/lib/x86_64-linux-gnu/crt1.o /usr/lib/crt1.o \
 && ln -sf /usr/lib/x86_64-linux-gnu/crti.o /usr/lib/crti.o \
 && ln -sf /usr/lib/x86_64-linux-gnu/crtn.o /usr/lib/crtn.o \
 && ln -sf /usr/lib/x86_64-linux-gnu/libpthread.so /usr/lib/libpthread.so \
 && ln -sf /usr/lib/x86_64-linux-gnu/libm.so /usr/lib/libm.so

# --- Create user ---
ARG USER=student
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} ${USER} \
 && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER} \
 && usermod -U ${USER} && passwd -d ${USER} \
 && echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER} \
 && mkdir -p /home/${USER}/.ssh \
 && chown -R ${USER}:${USER} /home/${USER}/.ssh \
 && chmod 700 /home/${USER} /home/${USER}/.ssh

# --- SSHD setup ---
RUN mkdir -p /var/run/sshd \
 && cat > /etc/ssh/sshd_config <<'EOF'
Port 22
PasswordAuthentication no
PermitRootLogin no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
X11Forwarding yes
X11UseLocalhost no
XAuthLocation /usr/bin/xauth
AddressFamily inet
AllowTcpForwarding yes
PermitTTY yes
UsePAM no
Subsystem sftp internal-sftp
EOF
EXPOSE 22

# --- Miniforge (conda-forge only) ---
ENV CONDA_DIR=/opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH
RUN wget -q https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O /tmp/m.sh \
 && bash /tmp/m.sh -b -p $CONDA_DIR \
 && rm /tmp/m.sh \
 && conda config --set channel_priority strict \
 && conda config --add channels conda-forge

# --- App lives in home ---
WORKDIR /home/${USER}/physical-cartpole
COPY --chown=${USER}:${USER} . .

# --- Conda env setup ---
ARG ENV_NAME=student-env
RUN conda env create -f environment.yml -n ${ENV_NAME} \
 && conda clean -afy \
 && if [ -f requirements.txt ] && [ -s requirements.txt ]; then \
      conda run -n ${ENV_NAME} pip install --no-cache-dir -r requirements.txt ; \
    fi

# --- Auto-activate env for user ---
RUN echo "source $CONDA_DIR/etc/profile.d/conda.sh" >> /home/${USER}/.bashrc \
 && echo "conda activate ${ENV_NAME}" >> /home/${USER}/.bashrc \
 && chown ${USER}:${USER} /home/${USER}/.bashrc

# --- Environment for Vivado/Qt ---
ENV QT_QPA_PLATFORM=xcb \
    LIBRARY_PATH=/usr/lib/x86_64-linux-gnu \
    C_INCLUDE_PATH=/usr/include/x86_64-linux-gnu

# --- Entrypoint ---
USER root
CMD ["/usr/sbin/sshd", "-D", "-e"]
