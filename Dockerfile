FROM ros:kinetic-robot-xenial


# ------------[ LOCALES SETUP ]------------
RUN apt-get update && \
    apt-get install -y locales && \
    locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    export LANG=en_US.UTF-8

# ------------[ ROS21 Kinetic INSTALLATION ]------------

RUN apt-get update && \
    apt-get install -y software-properties-common curl && \
    add-apt-repository universe
    
# install ros packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-kinetic-desktop \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    iputils-ping \
    wget \
    python-rosdep \
    python-rosinstall \
    python-rosinstall-generator \
    python-pip \
    python-wstool && \
    rm -rf /var/lib/apt/lists/* && \
    rm /etc/ros/rosdep/sources.list.d/20-default.list
    
# ------------[Alfarobi Project Dependencies]------------------
RUN apt update && \
    apt install -y ros-kinetic-gazebo-* \
    ros-kinetic-qt-gui \
    ros-kinetic-qt-ros \
    ros-kinetic-qt-build \
    ros-kinetic-op3-* \
    libncurses5-dev \
    libqt5serialport5-dev \
    libv4l-dev \
    ros-kinetic-tf2-eigen \
    libgl1-mesa-glx \
    libgl1-mesa-dri
    

RUN rosdep init && \
    rosdep update

# ------------[ PYTHON LIBRARIES ]------------
RUN apt-get update && \
    pip install --no-cache-dir \ 
    numpy \
    pyyaml \
    setuptools

# ------------[ DYNAMIXEL SDK INSTALLATION ]------------
#RUN git clone https://github.com/ROBOTIS-GIT/DynamixelSDK.git

#WORKDIR /DynamixelSDK/python

#RUN python setup.py install

RUN mkdir /home/alfarobi/
WORKDIR /home/alfarobi/

#RUN rm -rf /DynamixelSDK && \
#    apt-get remove -y git
    

# ------------[ BASH SETUP ]------------
RUN echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
RUN echo "#!/usr/bin/env bash" > /rcl_entrypoint.sh
RUN echo "source /opt/ros/kinetic/setup.bash" >> /rcl_entrypoint.sh
RUN echo 'exec "$@"' >> /rcl_entrypoint.sh
RUN chmod +x /rcl_entrypoint.sh

# ------------[ ENTRYPOINT AND LOOP ]------------
ENTRYPOINT ["/rcl_entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
