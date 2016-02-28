FROM ubuntu


###################### System reqs
# install requirements
ENV DEBIAN_FRONTEND noninteractive
RUN ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN \
  apt-get update && \
  apt-get install -y python-setuptools \
			python-software-properties \
			software-properties-common \
			curl \
			nano \
			vim \
			htop \
			tar \
			git \
			supervisor \
			openssh-server

ENV TERM=xterm
RUN sed -i 's|#AuthorizedKeysFile.*authorized_keys|AuthorizedKeysFile /etc/ssh/keys/authorized_keys|g' /etc/ssh/sshd_config
RUN mkdir -p /etc/ssh/keys && touch /etc/ssh/keys/authorized_keys
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd
############################################

############################## TSD specific
# Switch to root user
USER root

# Install tcollector
RUN git clone https://github.com/OpenTSDB/tcollector.git /opt/tcollector && \
	sed -i 's|# TSD_HOSTS=dns.name.of.tsd:portoftsd,other.name.of.tsd:portofothertsd|TSD_HOSTS=${TSD_HOSTS-"tsdb_rw:4242,localhost:8888"}|g' /opt/tcollector/startstop && \
	chmod +x /opt/tcollector/startstop && \
	mkdir -p /opt/tcollector/bin /opt/data/dump && \
	wget -O /opt/tcollector/bin/tsddrain.py 'https://raw.githubusercontent.com/OpenTSDB/opentsdb/master/tools/tsddrain.py'

# Add tcollector to PATH
ENV PATH=/opt/tcollector/bin:$PATH
############################################

############################ Modify configs
ADD etc/bin/* /opt/tcollector/bin/
ADD etc/supervisord.conf /etc/supervisord.conf
ADD etc/supervisord.d/* /etc/supervisord.d/
###########################################

############################# Cleanup
RUN apt-get clean autoremove autoclean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
###########################################

########################## Expose ports
# SSH
EXPOSE 22
###########################################


VOLUME ["/opt/data/dump", "/etc/ssh/keys"]

#Start supervisor
CMD ["/opt/tcollector/bin/startup.sh"]

