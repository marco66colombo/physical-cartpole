FROM condaforge/miniforge3:latest

# System setup
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies x11vnc xvfb \
    novnc websockify net-tools \
    xterm terminator firefox \
    git sudo locales \
    qt5-qmake qtbase5-dev build-essential \
    dbus-x11 \
    && apt-get clean

# Set up user and environment
RUN useradd -m student && echo "student:student" | chpasswd && adduser student sudo

WORKDIR /home/student

# Copy all repo files into container
COPY . .
RUN sudo chown -R student:student /home/student

USER student

# Create Conda env and install pip deps
COPY environment.yml .
RUN conda env create -f environment.yml
ENV PATH="/opt/conda/envs/student-env/bin:$PATH"
# RUN conda run -n student-env pip install -r requirements.txt

# Expose GUI ports
EXPOSE 5901 6080

# Start GUI (browser-ready)
CMD ["sh", "-c", "\
  export DISPLAY=:1 && \
  mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix && \
  Xvfb :1 -screen 0 1024x768x16 & \
  sleep 2 && \
  dbus-launch startxfce4 & \
  x11vnc -display :1 -forever -nopw -shared -bg && \
  websockify --web=/usr/share/novnc/ 6080 localhost:5901 \
"]
