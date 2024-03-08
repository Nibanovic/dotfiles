ARG ROS_DISTRO=humble

ENV ROS_DISTRO=${ROS_DISTRO}

ARG WORKDIR=/opt/underlay_ws

RUN echo "standard_bots" > /etc/debian_chroot

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


COPY ../standard_bots.repos src/standard_bots/
COPY ../standard_bots.upstream.repos src/standard_bots/

RUN vcs import src/ < ${PWD}/src/standard_bots/standard_bots.repos --skip-existing && \
    vcs import src/ < ${PWD}/src/standard_bots/standard_bots.upstream.repos --skip-existing && \
    git clone https://github.com/ros-planning/moveit2.git -b humble src/moveit2 && \
    for repo in src/moveit2/moveit2.repos $(f="moveit2/moveit2_$ROS_DISTRO.repos"; test -r $f && echo $f); do vcs import src/ < "$repo" --skip-existing; done && \
    # moveit2 tutorials and deps
    git clone https://github.com/ros-planning/moveit2_tutorials.git -b humble src/moveit2_tutorials && \
    vcs import src/ < ${PWD}/src/moveit2_tutorials/moveit2_tutorials.repos --skip-existing && \
    apt-get update && rosdep install -r --from-paths ./src --ignore-src --rosdistro $ROS_DISTRO -y


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
    nlohmann-json3-dev

COPY docker/entrypoint_bash.sh /usr/bin/
COPY docker/entrypoint_command.sh /usr/bin/
COPY docker/standard_bots.humble /usr/bin/entrypoint

RUN useradd -u 1000 -m -s /bin/bash control-box-bot

USER control-box-bot

ENV STANDARD_BOTS_WS /home/control-box-bot/standard_bots_ws

RUN mkdir -p $STANDARD_BOTS_WS

WORKDIR $STANDARD_BOTS_WS

COPY ./ ${STANDARD_BOTS_WS}/src/standard_bots

RUN source /opt/ros/humble/setup.bash && source /opt/underlay_ws/install/setup.bash \
    && colcon build --event-handlers desktop_notification- status- \
 --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo  -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
 --parallel-workers $(nproc)
