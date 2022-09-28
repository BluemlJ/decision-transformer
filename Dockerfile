FROM nvcr.io/nvidia/pytorch:22.07-py3
ENV FRAMEWORK="pytorch"

# Update aptitude with new repo
RUN apt-get update

# Install software 
RUN apt-get install -y git \
&& apt install unrar

# Install stuff for mujoco
RUN apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    git \
    libgl1-mesa-dev \
    libgl1-mesa-glx \
    libglew-dev \
    libglfw3 \
    libosmesa6-dev \
    software-properties-common \
    net-tools \
    vim \
    virtualenv \
    wget \
    xpra \
    xserver-xorg-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download mujoco
RUN mkdir -p /root/.mujoco \
    && wget https://mujoco.org/download/mujoco210-linux-x86_64.tar.gz -O mujoco.tar.gz \
    && tar -xf mujoco.tar.gz -C /root/.mujoco --no-same-owner\
    && rm mujoco.tar.gz

# Set Path variables
ENV LD_LIBRARY_PATH /root/.mujoco/mujoco210/bin:${LD_LIBRARY_PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib64:${LD_LIBRARY_PATH}

# Additional requrirements for mujoco DTs
RUN pip install transformers==4.5.1 \
&& pip install wandb==0.9.1 \
&& pip install mujoco-py
 
# Install minGPT for atari models
RUN git clone https://github.com/karpathy/minGPT.git \
&& cd minGPT \
&& pip install -e .

# Install gsutil
#RUN apt-get install -y gcc python-dev python-setuptools libffi-dev \
#&& apt-get install -y python3-pip \
RUN pip install gsutil

# Clone Fork
RUN cd /root \
&& git clone https://github.com/kzl/decision-transformer.git

# Install atari stuff
RUN pip install atari-py pyprind absl-py gin-config tqdm blosc \
&& pip install "gym[atari,accept-rom-license]" \
&& pip install git+https://github.com/google/dopamine.git \
&& pip install numpy==1.22.0 \
&& pip uninstall -y opencv-python \
&& pip install "opencv-python-headless<4.3" \
&& pip install rtpt \
&& pip install ipdb

RUN wget http://www.atarimania.com/roms/Roms.rar \
&& mkdir roms \
&& unrar x -o+ Roms.rar roms/ \
&& python -m atari_py.import_roms roms

# Install debugging utilities for "coredumpctl gdb"
RUN apt-get update -y \
     && apt-get install -y systemd-coredump \
     && apt-get install -y gdb \
     && apt-get clean \
     && rm -rf /var/lib/apt/lists/*
     
# checkout commit for tag 22.05
# cd /root/TensorRT \
# && git checkout 99a11a5fcdd1f184739bb20a8c4a473262c8ecc8 ; \
# ENV TENSORRT_PATH /root/TensorRT/
