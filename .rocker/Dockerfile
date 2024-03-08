###################################################
# EDIT VARIABLES BELOW, DEPENDING ON YOUR CONFIG: #
###################################################
ARG ROS_DISTRO=humble

ENV ROS_DISTRO=${ROS_DISTRO}

ARG WORKDIR=/opt/underlay_ws

# structure: project_ws/src/project_name/docker
# if your robot name is "blonk", you will have:
# blonk_ws/
#   src/
#       blonk/
#           docker/
#               blonk.<ros-distro>   <-- this is the rocker script
#               Dockerfile
#               entrypoint.sh        <-- script ran when entering container
#           .rocker                  <-- image build variables are here
#           package_1/
#           package_2/
#           ...

ARG PROJECT_NAME=maha
# user name in the container
ARG USER_NAME="$PROJECT_NAME-container"
# workspace name
ENV PROJECT_WS /home/${USER_NAME}/${PROJECT_NAME}_ws


###################################################

RUN echo ${PROJECT_NAME} > /etc/debian_chroot

WORKDIR ${WORKDIR}

ENV DEBIAN_FRONTEND noninteractive

# Install & configure dev tools
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update \
    && apt-get install -y \
        ccache \
        clang \
        clang-tidy \
        clang-tools \
        gdb \
        git \
        openssh-client \
        python3-pip \
        libxtst-dev \
        tmux \
        vim \
        wget \
        xterm \
        mesa-utils \
        libxcb-* \
        libxkbcommon* \
        libopengl0 \
        nano \
    && pip3 install black pre-commit \
    && pip3 install catmux \
    # Add missing ccache symlinks
    && test -f /usr/lib/ccache/c++ || ln -s ../../bin/ccache /usr/lib/ccache/c++ \
    && test -f /usr/lib/ccache/cc || ln -s ../../bin/ccache /usr/lib/ccache/cc


COPY ../${PROJECT_NAME}.repos src/${PROJECT_NAME}/
COPY ../${PROJECT_NAME}.upstream.repos src/${PROJECT_NAME}/

RUN vcs import src/ < ${PWD}/src/${PROJECT_NAME}/${PROJECT_NAME}.repos --skip-existing && \
    vcs import src/ < ${PWD}/src/${PROJECT_NAME}/${PROJECT_NAME}.upstream.repos --skip-existing && \
    ## moveit install ##
    git clone https://github.com/ros-planning/moveit2.git -b ${ROS_DISTRO} src/moveit2 && \
    for repo in src/moveit2/moveit2.repos $(f="moveit2/moveit2_$ROS_DISTRO.repos"; test -r $f && echo $f); do vcs import src/ < "$repo" --skip-existing; done && \
    apt-get update && rosdep install -r --from-paths ./src --ignore-src --rosdistro $ROS_DISTRO -y

    ## add gazebo and ros2 control


FROM base AS pkg_deps


ADD . src/standard_bots/

# Generate rosdeps script
RUN \
    apt-get update \
#    && set -o pipefail \
    && source /opt/ros/${ROS_DISTRO}/setup.bash \
    && rosdep install -y -s --rosdistro ${ROS_DISTRO} \
        --from-paths ./src /opt/underlay_ws/src --ignore-src \
        --skip-keys=joint_state_controller \
        --skip-keys=cmake_clang_tools --skip-keys=cmake_modules \
        | grep -v '^#' | sort \
        | tee /tmp/install_rosdeps.sh


FROM base AS standard_bots

# Pull in rosdeps script from temporary pkg_deps build stage
COPY --from=pkg_deps /tmp/install_rosdeps.sh /tmp/install_rosdeps.sh
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update \
    && bash -xe /tmp/install_rosdeps.sh

RUN --mount=type=cache,target=/ccache/ \
    touch src/standard_bots/COLCON_IGNORE \
    # Use ccache
    && export CCACHE_DIR=/ccache \
    && ccache -s \
    && ccache -z \
    && PATH=/usr/lib/ccache:$PATH \
    # workspace build and install
    && source /opt/ros/${ROS_DISTRO}/setup.bash \
    && apt remove --purge ros-${ROS_DISTRO}-moveit* -y \
    && CXXFLAGS=-g colcon build \
 #       --install-base /opt/ros/${ROS_DISTRO} --merge-install \
        --cmake-args -DCMAKE_BUILD_TYPE=Release \
    && ccache -s

RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update \
    && apt-get install -y \

COPY docker/entrypoint.sh /usr/bin/
COPY docker/${PROJECT_NAME}.humble /usr/bin/entrypoint

RUN useradd -u 1000 -m -s /bin/bash ${USER_NAME}

USER ${USER_NAME}

RUN mkdir -p $PROJECT_WS

WORKDIR $PROJECT_WS

COPY ./ ${PROJECT_WS}/src/${PROJECT_NAME}

RUN source /opt/ros/${ROS_DISTRO}/setup.bash && source /opt/underlay_ws/install/setup.bash \
    && colcon build --event-handlers desktop_notification- status- \
 --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo  -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
 --parallel-workers $(nproc)
