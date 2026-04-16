# IsaacSim-only image
# Runs setup_isaacsim.sh to create the hssim conda environment (Python 3.11)
# with IsaacSim 5.1.0, IsaacLab v2.3.0, and holosoma installed.
FROM nvcr.io/nvidia/isaac-sim:5.1.0

USER root

ENV LANG=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV WORKSPACE_DIR=/workspace
ENV CONDA_ROOT=/root/.holosoma_deps/miniconda3
ENV PATH=$CONDA_ROOT/bin:$PATH

RUN mkdir -p /var/lib/apt/lists/partial && \
    apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    build-essential \
    swig \
    curl \
    wget \
    unzip \
    git \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda (auto-detect architecture)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "aarch64" ]; then ARCH="aarch64"; else ARCH="x86_64"; fi && \
    curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-${ARCH}.sh -o /miniconda.sh && \
    bash /miniconda.sh -b -u -p $CONDA_ROOT && \
    rm /miniconda.sh

# Configure conda for non-interactive use
RUN echo ". $CONDA_ROOT/etc/profile.d/conda.sh" >> ~/.bashrc && \
    conda config --set always_yes true

RUN mkdir -p $WORKSPACE_DIR
WORKDIR $WORKSPACE_DIR

COPY . ./holosoma

RUN . $CONDA_ROOT/etc/profile.d/conda.sh && \
    cd /workspace/holosoma/scripts && \
    chmod +x setup_isaacsim.sh && \
    OMNI_KIT_ACCEPT_EULA=1 ./setup_isaacsim.sh


WORKDIR /workspace/holosoma

ENTRYPOINT []
CMD ["/bin/bash"]
