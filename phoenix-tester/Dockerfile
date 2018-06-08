FROM debian:stretch-slim
LABEL description="Test image for Phoenix"



#RUN wget https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.7.tar.gz \
#	&& echo "35cd349cddf78e4a0640d28ec8c7e88a2ae0db51ebd8926cd232bb70db2c7d7f  ruby-2.3.7.tar.gz" | sha256sum -c - \
#	&& tar -zxf ruby-2.3.7.tar.gz \
#	&& cd ruby-2.3.7 \
#	&& ./configure --disable-install-doc --with-readline-dir=/opt/bitnami/python/lib/python2.7/lib-dynload/ \
#	&& make \
#	&& make install


#ARG RUBY_VERSION=2.3.7
#ENV RUBY_VERSION=$RUBY_VERSION
#RUN gpg --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 \
#    && curl -sSL https://get.rvm.io | bash -s stable \
#    && /bin/bash -l -c "rvm install ${RUBY_VERSION}"
#ENV PATH=/usr/local/rvm/src/ruby-2.3.7/:${PATH}

#-----------------
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		bzip2 \
		ca-certificates \
		libffi-dev \
		libgdbm3 \
		libssl1.0-dev \
		libyaml-dev \
		procps \
		zlib1g-dev \
	&& rm -rf /var/lib/apt/lists/*

# skip installing gem documentation
RUN mkdir -p /usr/local/etc \
	&& { \
		echo 'install: --no-document'; \
		echo 'update: --no-document'; \
	} >> /usr/local/etc/gemrc

ENV RUBY_MAJOR 2.3
ENV RUBY_VERSION 2.3.7
ENV RUBY_DOWNLOAD_SHA256 c61f8f2b9d3ffff5567e186421fa191f0d5e7c2b189b426bb84498825d548edb
ENV RUBYGEMS_VERSION 2.7.7
ENV BUNDLER_VERSION 1.16.2

# some of ruby's build scripts are written in ruby
#   we purge system ruby later to make sure our final image uses what we just built
RUN set -ex \
	\
	&& buildDeps=' \
		autoconf \
		bison \
		dpkg-dev \
		gcc \
		libbz2-dev \
		libgdbm-dev \
		libglib2.0-dev \
		libncurses-dev \
		libreadline-dev \
		libxml2-dev \
		libxslt-dev \
		make \
		ruby \
		wget \
		xz-utils \
	' \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends $buildDeps \
	&& rm -rf /var/lib/apt/lists/* \
	\
	&& wget -O ruby.tar.xz "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR%-rc}/ruby-$RUBY_VERSION.tar.xz" \
	&& echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.xz" | sha256sum -c - \
	\
	&& mkdir -p /usr/src/ruby \
	&& tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1 \
	&& rm ruby.tar.xz \
	\
	&& cd /usr/src/ruby \
	\
# hack in "ENABLE_PATH_CHECK" disabling to suppress:
#   warning: Insecure world writable dir
	&& { \
		echo '#define ENABLE_PATH_CHECK 0'; \
		echo; \
		cat file.c; \
	} > file.c.new \
	&& mv file.c.new file.c \
	\
	&& autoconf \
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	&& ./configure \
		--build="$gnuArch" \
		--disable-install-doc \
		--enable-shared \
		--with-readline-dir=/usr/include/readline \
	&& make -j "$(nproc)" \
	&& make install \
	\
	&& dpkg-query --show --showformat '${package}\n' \
		| grep -P '^libreadline\d+$' \
		| xargs apt-mark manual \
	&& apt-get purge -y --auto-remove $buildDeps \
	&& cd / \
	&& rm -r /usr/src/ruby \
	\
	&& gem update --system "$RUBYGEMS_VERSION" \
	&& gem install bundler --version "$BUNDLER_VERSION" --force \
	&& rm -r /root/.gem/

# install things globally, for great justice
# and don't create ".bundle" in all our apps
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME" \
	BUNDLE_SILENCE_ROOT_WARNING=1 \
	BUNDLE_APP_CONFIG="$GEM_HOME"
# path recommendation: https://github.com/bundler/bundler/pull/6469#issuecomment-383235438
ENV PATH $GEM_HOME/bin:$BUNDLE_PATH/gems/bin:$PATH
# adjust permissions of a few directories for running "gem install" as an arbitrary user
RUN mkdir -p "$GEM_HOME" && chmod 777 "$GEM_HOME"
#-----------------

RUN apt-get update && apt-get install -y \
	ca-certificates \
	curl \
    default-libmysqlclient-dev \
	g++ \
	git \
	gnupg \
	libffi-dev \
    libsqlite3-dev \
	libssl1.0-dev \
	make \
    mysql-client \
    sqlite3 \
	unzip \
	wget \
    xvfb \
	zlib1g-dev \
	&& rm -rf /var/lib/apt/lists/*


RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list \
	&& wget https://dl-ssl.google.com/linux/linux_signing_key.pub \
	&& apt-key add linux_signing_key.pub \
	&& apt-get update && apt-get -y install google-chrome-stable \
	&& rm -rf /var/lib/apt/lists/*

#RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
#	&& dpkg -i google-chrome-stable_current_amd64.deb

# Install the latest chromedriver
RUN CHROMEDRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE` && \
    mkdir -p /opt/chromedriver-$CHROMEDRIVER_VERSION && \
    curl -sS -o /tmp/chromedriver_linux64.zip http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip && \
    unzip -qq /tmp/chromedriver_linux64.zip -d /opt/chromedriver-$CHROMEDRIVER_VERSION && \
    rm /tmp/chromedriver_linux64.zip && \
    chmod +x /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver && \
    ln -fs /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver /usr/local/bin/chromedriver

# Install node
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
	&& apt-get update \
	&& apt-get install -y nodejs \
	&& rm -rf /var/lib/apt/lists/*

# There are dependencies that require libssl1.0.0, which is no longer available in stretch
#RUN wget http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u8_amd64.deb \
#	&& dpkg -i libssl1.0.0*.deb

ENV PATH="/usr/lib/chromium:$PATH" \
    SOURCEDIR=/source \
    PHOENIX_DOCKER=1

RUN npm install --global yarn \
    && npm install --global coffeelint \
    && gem install bundler -N

WORKDIR /Wellframe
COPY database.yml database.yml
COPY docker-entrypoint.sh docker-entrypoint.sh
RUN chmod 0755 docker-entrypoint.sh

EXPOSE 3000

CMD [ "/usr/bin/tail", "-f", "/dev/null" ]
