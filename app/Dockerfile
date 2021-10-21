FROM alpine:3.10

COPY entrypoint.sh /
RUN ["chmod", "+x", "/entrypoint.sh"]

# Some ENV variables
ENV PATH="/mattermost/bin:${PATH}"
ENV MM_INSTALL_TYPE=docker

# Build argument to set Mattermost edition
ARG edition=$MATTERMOST_EDITION
ARG PUID=$PUID
ARG PGID=$PGID
ARG MM_BINARY=
ARG MM_VERSION=$MM_VERSION

# Environment
ENV MM_EDITION=${edition}

# Database environment variables
ENV DB_USE_SSL=${DB_USE_SSL}
ENV MM_DBHOST=${MM_DBHOST}
ENV MM_DBPORT=${MM_DBPORT}
ENV MM_SQLSETTINGS_DRIVERNAME=${MM_SQLSETTINGS_DRIVERNAME}
ENV MM_SQLSETTINGS_DATASOURCE=${MM_SQLSETTINGS_DATASOURCE}
ENV MM_DBNAME=${MM_DBNAME}

## Service environment variables
ENV MM_SERVICESETTINGS_SITEURL=${MM_SERVICESETTINGS_SITEURL}
ENV MM_SERVICESETTINGS_LISTENADDRESS=${MM_SERVICESETTINGS_LISTENADDRESS}

## Team environment variables
ENV MM_TEAMSETTINGS_SITENAME=${MM_TEAMSETTINGS_SITENAME}
ENV MM_TEAMSETTINGS_MAXUSERSPERTEAM=${MM_TEAMSETTINGS_MAXUSERSPERTEAM}
ENV MM_TEAMSETTINGS_RESTRICTCREATIONTODOMAINS=${MM_TEAMSETTINGS_RESTRICTCREATIONTODOMAINS}
ENV MM_TEAMSETTINGS_EXPERIMENTALPRIMARYTEAM=${MM_TEAMSETTINGS_EXPERIMENTALPRIMARYTEAM}

## Log environment variables
ENV MM_LOGSETTINGS_ENABLECONSOLE=${MM_LOGSETTINGS_ENABLECONSOLE}
ENV MM_LOGSETTINGS_CONSOLELEVEL=${MM_LOGSETTINGS_CONSOLELEVEL}

## File environment variables
ENV MM_FILESETTINGS_DIRECTORY=${MM_FILESETTINGS_DIRECTORY}
ENV MM_FILESETTINGS_ENABLEPUBLICLINK=${MM_FILESETTINGS_ENABLEPUBLICLINK}

## Email environment variables
ENV MM_EMAILSETTINGS_SENDEMAILNOTIFICATIONS=${MM_EMAILSETTINGS_SENDEMAILNOTIFICATIONS}
ENV MM_EMAILSETTINGS_REQUIREEMAILVERIFICATION=${MM_EMAILSETTINGS_REQUIREEMAILVERIFICATION}
ENV MM_EMAILSETTINGS_FEEDBACKNAME=${MM_EMAILSETTINGS_FEEDBACKNAME}
ENV MM_EMAILSETTINGS_FEEDBACKEMAIL=${MM_EMAILSETTINGS_FEEDBACKEMAIL}
ENV MM_EMAILSETTINGS_REPLYTOADDRESS=${MM_EMAILSETTINGS_REPLYTOADDRESS}
ENV MM_EMAILSETTINGS_FEEDBACKORGANIZATION=${MM_EMAILSETTINGS_FEEDBACKORGANIZATION}
ENV MM_EMAILSETTINGS_ENABLESMTPAUTH=${MM_EMAILSETTINGS_ENABLESMTPAUTH}
ENV MM_EMAILSETTINGS_SMTPUSERNAME=${MM_EMAILSETTINGS_SMTPUSERNAME}
ENV MM_EMAILSETTINGS_SMTPPASSWORD=${MM_EMAILSETTINGS_SMTPPASSWORD}
ENV MM_EMAILSETTINGS_SMTPSERVER=${MM_EMAILSETTINGS_SMTPSERVER}
ENV MM_EMAILSETTINGS_SMTPPORT=${MM_EMAILSETTINGS_SMTPPORT}
ENV MM_EMAILSETTINGS_CONNECTIONSECURITY=${MM_EMAILSETTINGS_CONNECTIONSECURITY}

## Rate limit environment variables
ENV MM_RATELIMITSETTINGS_ENABLE=${MM_RATELIMITSETTINGS_ENABLE}

## Plugin environment variables
ENV MM_PLUGINSETTINGS_DIRECTORY=${MM_PLUGINSETTINGS_DIRECTORY}



# Install some needed packages
RUN apk add --no-cache \
	ca-certificates \
	curl \
	jq \
	libc6-compat \
	libffi-dev \
	libcap \
	linux-headers \
	mailcap \
	netcat-openbsd \
	xmlsec-dev \
	tzdata \
	&& rm -rf /tmp/*

# Get Mattermost
RUN mkdir -p /mattermost/data /mattermost/plugins /mattermost/client/plugins \
	&& if [ ! -z "$MM_BINARY" ]; then curl $MM_BINARY | tar -xvz ; \
		elif [ "$edition" = "team" ] ; then curl https://releases.mattermost.com/$MM_VERSION/mattermost-team-$MM_VERSION-linux-amd64.tar.gz?src=docker-app | tar -xvz ; \
		else curl https://releases.mattermost.com/$MM_VERSION/mattermost-$MM_VERSION-linux-amd64.tar.gz?src=docker-app | tar -xvz ; fi \
	&& cp /mattermost/config/config.json /config.json.save \
	&& rm -rf /mattermost/config/config.json \
	&& addgroup -g ${PGID} mattermost \
	&& adduser -D -u ${PUID} -G mattermost -h /mattermost -D mattermost \
	&& chown -R mattermost:mattermost /mattermost /config.json.save /mattermost/plugins /mattermost/client/plugins \
	&& setcap cap_net_bind_service=+ep /mattermost/bin/mattermost


USER mattermost

#Healthcheck to make sure container is ready
HEALTHCHECK CMD curl --fail http://localhost:8000 || exit 1

# Configure entrypoint and command
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /mattermost
CMD ["mattermost"]

# Expose port 8000 of the container
EXPOSE 8000

# Declare volumes for mount point directories
VOLUME ["/mattermost/data", "/mattermost/logs", "/mattermost/config", "/mattermost/plugins", "/mattermost/client/plugins"]
