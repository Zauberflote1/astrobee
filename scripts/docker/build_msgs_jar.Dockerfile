# Copyright (c) 2021, United States Government, as represented by the
# Administrator of the National Aeronautics and Space Administration.
#
# All rights reserved.
#
# The "ISAAC - Integrated System for Autonomous and Adaptive Caretaking
# platform" software is licensed under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with the
# License. You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

# This will set up an Astrobee docker container using the non-NASA install instructions.
# You must set the docker context to be the repository root directory

ARG REMOTE=astrobee
ARG REPO=astrobee
FROM ${REMOTE}/${REPO}:msgs-ubuntu20.04

COPY scripts/setup/debians/rosjava /src/msgs/src/scripts

# make sure there is a python binary
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# install dependencies for rosjava build script
RUN apt-get update && apt-get install -y devscripts equivs

# build rosjava debians
RUN cd /src/msgs/src/scripts \
    && /bin/bash build_rosjava_debians.sh --install-with-deps \
    && rm -rf /var/lib/apt/lists/*

# compile msg jar files, genjava_message_artifacts only works with bash
RUN ["/bin/bash", "-c", "cd /src/msgs \
  && catkin config \
  && catkin build \
  && . devel/setup.bash \
  && genjava_message_artifacts --verbose -p ff_msgs ff_hw_msgs isaac_msgs isaac_hw_msgs"]
