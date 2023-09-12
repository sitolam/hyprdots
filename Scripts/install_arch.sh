#!/bin/bash
cat << EOF >> /etc/profile
#locale settings
export LANG=en_US.UTF-8
#export LANGUAGE="en_US:en"
export LC_MESSAGES="en_US.UTF-8"
export LC_CTYPE="nl_BE@euro"
export LC_COLLATE="nl_BE@euro"
export LC_TIME="nl_BE"
export LC_NUMERIC="nl_BE"
export LC_MONETARY="nl_BE@euro"
export LC_PAPER="nl_BE"
export LC_TELEPHONE="nl_BE"
export LC_ADDRESS="nl_BE"
export LC_MEASUREMENT="nl_BE"
export LC_NAME="nl_BE"
EOF

cat > /etc/locale.conf << EOF
LANG=en_US.UTF-8
#export LANGUAGE="en_US:en"
LC_MESSAGES="en_US.UTF-8"
LC_CTYPE="nl_BE@euro"
LC_COLLATE="nl_BE@euro"
LC_TIME="nl_BE"
LC_NUMERIC="nl_BE"
LC_MONETARY="nl_BE@euro"
LC_PAPER="nl_BE"
LC_TELEPHONE="nl_BE"
LC_ADDRESS="nl_BE"
LC_MEASUREMENT="nl_BE"
LC_NAME="nl_BE"
EOF