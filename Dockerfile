FROM aiplanning/planutils:latest

# Install solvers and tools
RUN planutils install -y val
RUN planutils install -y ff
RUN planutils install -y metric-ff
RUN planutils install -y enhsp
RUN planutils install -y popf
RUN planutils install -y optic
RUN planutils install -y tfd
RUN planutils install -y downward

# Modify the configuration file to enable hostfs, i.e. use the host file system
RUN perl -pi.bak -e "s/mount hostfs = no/mount hostfs = yes/g" /etc/apptainer/apptainer.conf


CMD /bin/bash


# To build the docker image
# docker build --rm  --tag myplauntils . --file Dockerfile

# To to run the built image
# docker run  -v.:/computer -it --privileged --rm myplanutils bash

# Alternatively, you can use the following command to run the image if the above command does not work
# docker run  -v.:/computer -it --privileged --rm docker.io/library/myplauntils bash

# With -v option, you can mount any folder of the host computer to the container,
# e.g. docker run -v /home/user:/computer -it --privileged --rm myplanutils bash
# This will mount the /home/user folder of the host computer to the /computer folder of the container
