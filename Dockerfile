FROM accetto/ubuntu-vnc-xfce-g3

# Switch to root for system operations
USER 0

RUN apt-get update && apt-get install -y \
        wget \
        bash \
        git \
        qtbase5-dev \
        libxkbcommon-x11-0 \
        qt5-qmake \
        qtchooser \
        qtbase5-dev-tools \
        libxcb-cursor0 \
        libxcb-icccm4 \
        libxcb-image0 \
        libxcb-keysyms1 \
        libxcb-render-util0 \
        libgl1 \
        libegl1 \
        && rm -rf /var/lib/apt/lists/*

ENV CONDA_DIR=/opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p $CONDA_DIR && \
    rm /tmp/miniconda.sh && \
    $CONDA_DIR/bin/conda init bash && \
    echo "source $CONDA_DIR/etc/profile.d/conda.sh" >> /home/headless/.bashrc && \
    echo "conda activate base" >> /home/headless/.bashrc

RUN mkdir -p /home/headless/cartpole-demo
COPY . /home/headless/cartpole-demo/

RUN conda env create -f /home/headless/cartpole-demo/environment.yml || true

RUN chown -R headless:headless /home/headless/cartpole-demo

RUN conda run -n student-env pip install -r /home/headless/requirements.txt

RUN chmod 666 /etc/passwd /etc/group

USER "${HEADLESS_USER_ID}"