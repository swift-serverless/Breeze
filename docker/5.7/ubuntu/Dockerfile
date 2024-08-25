FROM swift:5.7.3 as builder

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && apt-get -q update && apt-get -q install -y make curl wget