FROM ros:kinetic-robot-xenial


# ------------[ LOCALES SETUP ]------------
RUN apt-get update && \
    apt-get install -y locales && \
    locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    export LANG=en_US.UTF-8

# ------------[ ROS21 Kinetic INSTALLATION ]------------

RUN apt-get update && \
    apt-get install -y software-properties-common curl

    
# install ros packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-kinetic-desktop


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
    rm /etc/ros/rosdep/sources.list.d/20-default.list
    
# ------------[Alfarobi Project Dependencies]------------------
RUN apt-get update && \
    apt-get install -y \
    ros-kinetic-qt-gui \
    ros-kinetic-qt-ros \
    ros-kinetic-qt-build \
    ros-kinetic-vision-msgs \
    libncurses5-dev \
    libqt5serialport5-dev \
    libv4l-dev \
    ros-kinetic-tf2-eigen

RUN rosdep init && \
    rosdep update

    
# ------------[ PYTHON LIBRARIES ]------------
RUN apt-get install python3
RUN apt-get install -y python3-dev python3-pip python3-testresources python3-venv
RUN python3 --version && python3 -m pip install --upgrade pip setuptools wheel
RUN python -m pip install testresources
# RUN python3 -m pip install \ 
#     numpy \
#     pyyaml \
#     wheel numpy scipy scikit-image scikit-learn ipython dlib

# ------------[ DYNAMIXEL SDK INSTALLATION ]------------
RUN git clone https://github.com/Lexciese/DynamixelSDK.git

WORKDIR /DynamixelSDK/c++/build/linux_sbc
RUN make && make install

# ------------[ QT INSTALLATION ]------------
RUN add-apt-repository -y ppa:levi-armstrong/ppa && add-apt-repository -y ppa:levi-armstrong/qt-libraries-xenial && apt-get update && apt-get install -y qt59creator qt57creator-plugin-ros qt59serialport qt59charts-no-lgpl
    
WORKDIR /
# ------------[ openCV INSTALLATION ]------------
RUN apt -y remove x264 libx264-dev
 
## Install dependencies
RUN apt-get install -y build-essential \
    checkinstall \
    cmake \
    pkg-config \
    yasm \
    git \
    gfortran \
    libjpeg8-dev \
    libjasper-dev \
    libpng12-dev \
    libtiff5-dev \
    libtiff-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libdc1394-22-dev \
    libxine2-dev \
    libv4l-dev \
    && cd /usr/include/linux \
    && ln -s -f ../libv4l1-videodev.h videodev.h
 
RUN apt install -y libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev \
    libgtk2.0-dev libtbb-dev qt5-default \
    libatlas-base-dev \
    libfaac-dev libmp3lame-dev libtheora-dev \
    libvorbis-dev libxvidcore-dev \
    libopencore-amrnb-dev libopencore-amrwb-dev \
    libavresample-dev \
    x264 v4l-utils

WORKDIR /

RUN python3 --version && export cvVersion="3.4.4" \
    && git clone https://github.com/opencv/opencv.git \
    && cd opencv \
    && git checkout $cvVersion \
    && cd ..

RUN export cvVersion="3.4.4" \
    && git clone https://github.com/opencv/opencv_contrib.git \
    && cd opencv_contrib \
    && git checkout $cvVersion \
    && cd ..

RUN cd opencv && mkdir build && cd build && export cvVersion="3.4.4" \
    && cmake -D CMAKE_BUILD_TYPE=RELEASE \
            -D CMAKE_INSTALL_PREFIX=/usr/local \
            -D INSTALL_C_EXAMPLES=ON \
            -D INSTALL_PYTHON_EXAMPLES=ON \
            -D WITH_TBB=ON \
            -D WITH_V4L=ON \
            -D OPENCV_PYTHON3_INSTALL_PATH=/usr/local/lib/python3.5/dist-packages \
        -D WITH_QT=ON \
        -D WITH_OPENGL=ON \
        -D OPENCV_EXTRA_MODULES_PATH=/opencv_contrib/modules \
        -D BUILD_EXAMPLES=ON ..

RUN cd /opencv/build && make -j4 && make install

RUN mkdir /home/alfarobi/
WORKDIR /home/alfarobi/

RUN apt install -y mesa-utils
RUN pip install pyserial
    

# ------------[ BASH SETUP ]------------
RUN echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
RUN echo "source /home/alfarobi/alfarobi_ws/devel/setup.bash" >> ~/.bashrc
RUN echo "#!/usr/bin/env bash" > /rcl_entrypoint.sh
RUN echo "source /opt/ros/kinetic/setup.bash" >> /rcl_entrypoint.sh
RUN echo "source /home/alfarobi/alfarobi_ws/devel/setup.bash" >> /rcl_entrypoint.sh
RUN echo 'exec "$@"' >> /rcl_entrypoint.sh
RUN chmod +x /rcl_entrypoint.sh

# ------------[ ENTRYPOINT AND LOOP ]------------
ENTRYPOINT ["/rcl_entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
