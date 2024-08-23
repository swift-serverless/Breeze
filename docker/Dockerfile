FROM swift:5.10 as builder

# amazonlinux2
# RUN yum -y update && \
#     yum -y install git make

# Ubuntu
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && apt-get -q update && apt-get -q install -y make curl wget