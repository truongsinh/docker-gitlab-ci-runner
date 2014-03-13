FROM ubuntu:12.04
MAINTAINER sameer@damagehead.com

RUN sed 's/main$/main universe/' -i /etc/apt/sources.list
RUN apt-get update # 20140310

# essentials
RUN apt-get install -y vim curl wget sudo net-tools pwgen && \
	apt-get install -y logrotate supervisor openssh-server && \
	apt-get clean

# build tools
RUN apt-get install -y gcc make && apt-get clean

# image specific
RUN apt-get install -y unzip build-essential zlib1g-dev libyaml-dev libssl-dev libreadline-dev && \
		apt-get clean

RUN apt-get install -y python-software-properties && \
		add-apt-repository -y ppa:git-core/ppa && apt-get update && \
		apt-get install -y libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev libpq-dev git-core postfix && \
		apt-get clean

RUN wget ftp://ftp.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p353.tar.gz -O - | tar -zxf - -C /tmp/ && \
		cd /tmp/ruby-2.0.0-p353/ && \
		./configure --disable-install-rdoc --enable-pthread --prefix=/usr && \
		make && make install && \
		cd /tmp && rm -rf /tmp/ruby-2.0.0-p353 && \
		gem install --no-ri --no-rdoc bundler

ADD assets/ /app/
RUN mv /app/.vimrc /app/.bash_aliases /root/
RUN chmod 755 /app/init /app/setup/install && /app/setup/install

ADD authorized_keys /root/.ssh/
RUN chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys && chown root:root -R /root/.ssh

EXPOSE 22

ENTRYPOINT ["/app/init"]
CMD ["app:start"]
