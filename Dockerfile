FROM accetto/ubuntu-vnc-xfce-g3

# Set the default working directory
WORKDIR /home/cartpole-demo

# Install wget and bash for Conda installer
USER root
RUN apt-get update && apt-get install -y wget bash && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda (or you can switch to Mambaforge if preferred)
ENV CONDA_DIR=/opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p $CONDA_DIR && \
    rm /tmp/miniconda.sh

# Copy your code into the image
COPY . .

# Optionally, create a conda env from environment.yml
COPY environment.yml .
RUN conda env create -f environment.yml || true
RUN conda run -n student-env pip install -r requirements.txt

# Ensure permissions are correct (optional, depending on base image's user)
RUN chown -R developer:developer /home/developer

# Switch back to non-root user (as used by accetto's image)
USER developer

# Set working directory
WORKDIR /home/developer/my-code
