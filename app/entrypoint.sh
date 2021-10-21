#!/bin/sh

# Function to generate a random salt
generate_salt() {
  tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 48 | head -n 1
}

# Read environment variables or set default values
## config file
MM_CONFIG=${MM_CONFIG:-/mattermost/config/config.json}

## Database environment variables
MM_DBHOST=${MM_DBHOST:-db}
MM_DBPORT=${MM_DBPORT:-5432}
MM_SQLSETTINGS_DRIVERNAME=${MM_SQLSETTINGS_DRIVERNAME:-postgres}
MM_SQLSETTINGS_DATASOURCE=${MM_SQLSETTINGS_DATASOURCE}
DB_USE_SSL=${DB_USE_SSL:-disable}
MM_DBNAME=${MM_DBNAME:-mattermost}
MM_SQLSETTINGS_ATRESTENCRYPTKEY="$(generate_salt)"

## Service environment variables
MM_SERVICESETTINGS_SITEURL=${MM_SERVICESETTINGS_SITEURL:-"www.example.org"}
MM_SERVICESETTINGS_LISTENADDRESS=${MM_SERVICESETTINGS_LISTENADDRESS:-:8000}

## Team environment variables
MM_TEAMSETTINGS_SITENAME=${MM_TEAMSETTINGS_SITENAME:-"Mattermost"}
MM_TEAMSETTINGS_MAXUSERSPERTEAM=${MM_TEAMSETTINGS_MAXUSERSPERTEAM:-50}
MM_TEAMSETTINGS_RESTRICTCREATIONTODOMAINS=${MM_TEAMSETTINGS_RESTRICTCREATIONTODOMAINS:-""}
MM_TEAMSETTINGS_EXPERIMENTALPRIMARYTEAM=${MM_TEAMSETTINGS_EXPERIMENTALPRIMARYTEAM:-[]}

## Log environment variables
MM_LOGSETTINGS_ENABLECONSOLE=${MM_LOGSETTINGS_ENABLECONSOLE:-true}
MM_LOGSETTINGS_CONSOLELEVEL=${MM_LOGSETTINGS_CONSOLELEVEL:-"ERROR"}

## File environment variables
MM_FILESETTINGS_DIRECTORY=${MM_FILESETTINGS_DIRECTORY:-"/mattermost/data/"}
MM_FILESETTINGS_ENABLEPUBLICLINK=${MM_FILESETTINGS_ENABLEPUBLICLINK:-true}
MM_FILESETTINGS_PUBLICLINKSALT="$(generate_salt)"

## Email environment variables
MM_EMAILSETTINGS_SENDEMAILNOTIFICATIONS=${MM_EMAILSETTINGS_SENDEMAILNOTIFICATIONS:-false}
MM_EMAILSETTINGS_REQUIREEMAILVERIFICATION=${MM_EMAILSETTINGS_REQUIREEMAILVERIFICATION:-false}
MM_EMAILSETTINGS_FEEDBACKNAME=${MM_EMAILSETTINGS_FEEDBACKNAME:-""}
MM_EMAILSETTINGS_FEEDBACKEMAIL=${MM_EMAILSETTINGS_FEEDBACKEMAIL:-""}
MM_EMAILSETTINGS_REPLYTOADDRESS=${MM_EMAILSETTINGS_REPLYTOADDRESS:-""}
MM_EMAILSETTINGS_FEEDBACKORGANIZATION=${MM_EMAILSETTINGS_FEEDBACKORGANIZATION:-""}
MM_EMAILSETTINGS_ENABLESMTPAUTH=${MM_EMAILSETTINGS_ENABLESMTPAUTH:-false}
MM_EMAILSETTINGS_SMTPUSERNAME=${MM_EMAILSETTINGS_SMTPUSERNAME:-""}
MM_EMAILSETTINGS_SMTPPASSWORD=${MM_EMAILSETTINGS_SMTPPASSWORD:-""}
MM_EMAILSETTINGS_SMTPSERVER=${MM_EMAILSETTINGS_SMTPSERVER:-""}
MM_EMAILSETTINGS_SMTPPORT=${MM_EMAILSETTINGS_SMTPPORT:-}
MM_EMAILSETTINGS_CONNECTIONSECURITY=${MM_EMAILSETTINGS_CONNECTIONSECURITY:-""}

## Rate limit environment variables
MM_RATELIMITSETTINGS_ENABLE=${MM_RATELIMITSETTINGS_ENABLE:-true}

## Plugin environment variables
MM_PLUGINSETTINGS_DIRECTORY=${MM_PLUGINSETTINGS_DIRECTORY:-"/mattermost/plugins/"}

_1=$(echo "$1" | awk '{ s=substr($0, 0, 1); print s; }')
if [ "$_1" = '-' ]; then
  set -- mattermost "$@"
fi

if [ "$1" = 'mattermost' ]; then
  # Check CLI args for a -config option
  for ARG in "$@"; do
    case "$ARG" in
    -config=*) MM_CONFIG=${ARG#*=} ;;
    esac
  done

  if [ ! -f "$MM_CONFIG" ]; then
    # If there is no configuration file, create it with some default values
    echo "No configuration file $MM_CONFIG"
    echo "Creating a new one"
    # Copy default configuration file
    cp /config.json.save "$MM_CONFIG"
    # Substitute some parameters with jq
    jq --arg v $MM_SERVICESETTINGS_SITEURL '.ServiceSettings.SiteURL = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_SERVICESETTINGS_LISTENADDRESS '.ServiceSettings.ListenAddress = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_TEAMSETTINGS_SITENAME '.TeamSettings.SiteName = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_TEAMSETTINGS_MAXUSERSPERTEAM '.TeamSettings.MaxUsersPerTeam = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_TEAMSETTINGS_RESTRICTCREATIONTODOMAINS '.TeamSettings.RestrictCreationToDomains = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_TEAMSETTINGS_EXPERIMENTALPRIMARYTEAM '.TeamSettings.ExperimentalPrimaryTeam = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_LOGSETTINGS_ENABLECONSOLE '.LogSettings.EnableConsole = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_LOGSETTINGS_CONSOLELEVEL '.LogSettings.ConsoleLevel = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_FILESETTINGS_DIRECTORY '.FileSettings.Directory = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_FILESETTINGS_ENABLEPUBLICLINK '.FileSettings.EnablePublicLink = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_FILESETTINGS_PUBLICSALT '.FileSettings.PublicLinkSalt = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_EMAILSETTINGS_SENDEMAILNOTIFICATIONS '.EmailSettings.SendEmailNotifications = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_EMAILSETTINGS_REQUIREEMAILVERIFICATION '.EmailSettings.RequireEmailVerification = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_EMAILSETTINGS_FEEDBACKNAME '.EmailSettings.FeedbackName = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_EMAILSETTINGS_FEEDBACKEMAIL '.EmailSettings.FeedbackEmail = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_EMAILSETTINGS_REPLYTOADDRESS '.EmailSettings.ReplyToAddress = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_EMAILSETTINGS_FEEDBACKORGANIZATION '.EmailSettings.FeedbackOrganization = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_EMAILSETTINGS_ENABLESMTPAUTH '.EmailSettings.EnableSMTPAuth = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_EMAILSETTINGS_SMTPUSERNAME '.EmailSettings.SMTPUsername = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_EMAILSETTINGS_SMTPPASSWORD '.EmailSettings.SMTPPassword = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_EMAILSETTINGS_SMTPSERVER '.EmailSettings.SMTPServer = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_EMAILSETTINGS_SMTPPORT '.EmailSettings.SMTPPort = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_EMAILSETTINGS_CONNECTIONSECURITY '.EmailSettings.ConnectionSecurity = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq ".EmailSettings.InviteSalt = \"$(generate_salt)\"" "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq ".EmailSettings.PasswordResetSalt = \"$(generate_salt)\"" "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_RATELIMITSETTINGS_ENABLE '.RateLimitSettings.Enable = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_SQLSETTINGS_DRIVERNAME '.SqlSettings.DriverName = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_SQLSETTINGS_DATASOURCE '.SqlSettings.DataSource = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_SQLSETTINGS_ATRESTENCRYPTKEY '.SqlSettings.AtRestEncryptKey = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    jq --arg v $MM_PLUGINSETTINGS_DIRECTORY '.PluginSettings.Directory = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
  else
    echo "Using existing config file $MM_CONFIG"
  fi

  # Configure database access
  if [ -z "$MM_SQLSETTINGS_DATASOURCE" ] && [ -n "$MM_USERNAME" ] && [ -n "$MM_PASSWORD" ]; then
    echo "Configure database connection..."
    # URLEncode the password, allowing for special characters
    ENCODED_PASSWORD=$(printf %s "$MM_PASSWORD" | jq -s -R -r @uri)
    MM_SQLSETTINGS_DATASOURCE="postgres://$MM_USERNAME:$ENCODED_PASSWORD@$MM_DBHOST:$MM_DBPORT/$MM_DBNAME?sslmode=$DB_USE_SSL&connect_timeout=10"
    jq --arg v $MM_SQLSETTINGS_DATASOURCE '.SqlSettings.DataSource = $v' "$MM_CONFIG" >"$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
    echo "OK"
  else
    echo "Using existing database connection"
  fi


  # Wait another second for the database to be properly started.
  # Necessary to avoid "panic: Failed to open sql connection pq: the database system is starting up"
  sleep 1

  echo "Starting mattermost"
fi

exec "$@"
