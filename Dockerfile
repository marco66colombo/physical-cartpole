FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# --- System packages ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo wget curl ca-certificates git xz-utils bzip2 locales tzdata \
    openssh-server xauth x11-apps \
    libxkbcommon-x11-0 libxcb-cursor0 libxcb-icccm4 libxcb-image0 \
    libxcb-keysyms1 libxcb-render-util0 libgl1 libegl1 libxrandr2 \
    libxrender1 libxinerama1 libfontconfig1 libfreetype6 libxi6 libtinfo6 \
 && rm -rf /var/lib/apt/lists/*

# --- Create user ---
ARG USER=student
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} ${USER} \
 && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER} \
 && echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER}

# --- SSHD setup ---
RUN mkdir -p /var/run/sshd /home/${USER}/.ssh \
 && chown -R ${USER}:${USER} /home/${USER}/.ssh \
 && sed -i 's/#X11Forwarding yes/X11Forwarding yes/' /etc/ssh/sshd_config \
 && sed -i 's/#X11UseLocalhost yes/X11UseLocalhost yes/' /etc/ssh/sshd_config \
 && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config \
 && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
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
WORKDIR /home/${USER}/app
COPY --chown=${USER}:${USER} . .

# Create conda env from environment.yml
ARG ENV_NAME=student-env
RUN conda env create -f environment.yml -n ${ENV_NAME} \
 && conda clean -afy \
 && if [ -f requirements.txt ] && [ -s requirements.txt ]; then \
      conda run -n ${ENV_NAME} pip install --no-cache-dir -r requirements.txt ; \
    fi

# Auto-activate env for user
RUN echo "source $CONDA_DIR/etc/profile.d/conda.sh" >> /home/${USER}/.bashrc \
 && echo "conda activate ${ENV_NAME}" >> /home/${USER}/.bashrc \
 && chown ${USER}:${USER} /home/${USER}/.bashrc


# --- Vivado libtinfo compat ---
RUN ln -sf /usr/lib/x86_64-linux-gnu/libtinfo.so.6 /usr/lib/x86_64-linux-gnu/libtinfo.so.5

USER ${USER}
CMD ["/usr/sbin/sshd", "-D", "-e"]
