FROM accetto/ubuntu-vnc-xfce-g3


# Switch to root for system operations
USER 0

RUN apt-get update && apt-get install -y wget bash && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda (or you can switch to Mambaforge if preferred)
ENV CONDA_DIR=/opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p $CONDA_DIR && \
    rm /tmp/miniconda.sh

RUN mkdir -p /home/headless/cartpole-demo
WORKDIR /home/headless/cartpole-demo
COPY . .

# Optionally, create a conda env from environment.yml
COPY environment.yml .
RUN conda env create -f environment.yml || true
# RUN conda run -n student-env pip install -r requirements.txt

RUN chmod 666 /etc/passwd /etc/group

# RUN chown -R headless:headless /home/headless/cartpole-demo
# USER headless
# RUN echo "source activate student-env" >> ~/.bashrc