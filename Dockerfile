# Need devel version cause we need /usr/include/cudnn.h 
# for compiling libctc_decoder_with_kenlm.so
FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04


# >> START Install base software

# Get basic packages
RUN apt-get update && apt-get install -y --no-install-recommends \
        apt-utils \
        build-essential \
        curl \
        wget \
        git \
        python3 \
        python3-dev \
        python3-pip \
        python3-wheel \
        python3-venv \
        libcurl3-dev  \
        ca-certificates \
        gcc \
        sox \
        libsox-fmt-mp3 \
        htop \
        nano \
        cmake \
        libboost-all-dev \
        zlib1g-dev \
        libbz2-dev \
        liblzma-dev \
        locales \
        pkg-config \
        libpng-dev \
        libsox-dev \
        libmagic-dev \
        libgsm1-dev \
        libltdl-dev \
        openjdk-8-jdk \
        bash-completion \
        g++ \
        unzip

RUN ln -s -f /usr/bin/python3 /usr/bin/python

# Install NCCL 2.2
RUN apt-get --no-install-recommends install -qq -y --allow-downgrades --allow-change-held-packages libnccl2=2.3.7-1+cuda10.0 libnccl-dev=2.3.7-1+cuda10.0

# Install CUDA CLI Tools
RUN apt-get --no-install-recommends install -qq -y cuda-command-line-tools-10-0

# Install pip
RUN wget https://bootstrap.pypa.io/get-pip.py && \
    python3 get-pip.py && \
    rm get-pip.py

#COPY ./cudnn ./cudnn
#
#RUN dpkg -i /cudnn/libcudnn7_7.4.2.24-1+cuda10.0_amd64.deb
#RUN dpkg -i /cudnn/libcudnn7-dev_7.4.2.24-1+cuda10.0_amd64.deb

#RUN python3 -m venv $HOME/tmp/deepspeech-train-venv/
#RUN source $HOME/tmp/deepspeech-train-venv/bin/activate

# << END Install base software


# >> START Configure Tensorflow Build

# GPU Environment Setup
ENV TF_NEED_CUDA 1
ENV TF_CUDA_PATHS "/usr/local/cuda,/usr/lib/x86_64-linux-gnu/"
ENV TF_CUDA_VERSION 10.0
ENV TF_CUDNN_VERSION 7
ENV TF_CUDA_COMPUTE_CAPABILITIES 6.0
ENV TF_NCCL_VERSION 2.3

# Common Environment Setup
ENV TF_BUILD_CONTAINER_TYPE GPU
ENV TF_BUILD_OPTIONS OPT
ENV TF_BUILD_DISABLE_GCP 1
ENV TF_BUILD_ENABLE_XLA 0
ENV TF_BUILD_PYTHON_VERSION PYTHON3
ENV TF_BUILD_IS_OPT OPT
ENV TF_BUILD_IS_PIP PIP

# Other Parameters
ENV CC_OPT_FLAGS -mavx -mavx2 -msse4.1 -msse4.2 -mfma
ENV TF_NEED_GCP 0
ENV TF_NEED_HDFS 0
ENV TF_NEED_JEMALLOC 1
ENV TF_NEED_OPENCL 0
ENV TF_CUDA_CLANG 0
ENV TF_NEED_MKL 0
ENV TF_ENABLE_XLA 0
ENV TF_NEED_AWS 0
ENV TF_NEED_KAFKA 0
ENV TF_NEED_NGRAPH 0
ENV TF_DOWNLOAD_CLANG 0
ENV TF_NEED_TENSORRT 0
ENV TF_NEED_GDR 0
ENV TF_NEED_VERBS 0
ENV TF_NEED_OPENCL_SYCL 0
ENV PYTHON_BIN_PATH /usr/bin/python3.6
ENV PYTHON_LIB_PATH /usr/lib/python3.6/dist-packages

# << END Configure Tensorflow Build

# Put cuda libraries to where they are expected to be
RUN mkdir /usr/local/cuda/lib &&  \
    ln -s /usr/lib/x86_64-linux-gnu/libnccl.so.2 /usr/local/cuda/lib/libnccl.so.2 && \
    ln -s /usr/include/nccl.h /usr/local/cuda/include/nccl.h && \
    ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1 && \
    ln -s /usr/include/cudnn.h /usr/local/cuda/include/cudnn.h


# Set library paths
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/cuda/extras/CUPTI/lib64:/usr/local/cuda/lib64:/usr/lib/x86_64-linux-gnu/:/usr/local/cuda/lib64/stubs/

# Copy DeepSpeech repo contents to container's /DeepSpeech
#COPY . /DeepSpeech/
# Alternative clone from GitHub
RUN apt-get update && apt-get install -y git-lfs
RUN git lfs install
WORKDIR /
RUN git clone https://github.com/mozilla/DeepSpeech.git
WORKDIR /DeepSpeech
RUN git checkout v0.7.0

WORKDIR /DeepSpeech

RUN DS_NODECODER=1 pip3 --no-cache-dir install .

RUN pip3 install --upgrade pip==20.0.2 wheel==0.34.2 setuptools==46.1.3
RUN pip3 install --upgrade --force-reinstall -e .

# Install TensorFlow
WORKDIR /DeepSpeech/
RUN pip3 install tensorflow-gpu==1.15.2

# Allow Python printing utf-8
ENV PYTHONIOENCODING UTF-8
