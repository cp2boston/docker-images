FROM wf-ruby:debian-stretch-2.3.7
LABEL description="Test image for Phoenix"

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
	&& gem update --system \
    && gem install bundler -N

WORKDIR /Wellframe
COPY database.yml database.yml
COPY docker-entrypoint.sh docker-entrypoint.sh
RUN chmod 0755 docker-entrypoint.sh
COPY build-load-data-db.sh build-load-data-db.sh
RUN chmod 0755 build-load-data-db.sh

EXPOSE 3000

CMD [ "/usr/bin/tail", "-f", "/dev/null" ]
