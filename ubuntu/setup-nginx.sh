#!/bin/sh

WHOAMI=`python -c 'import os, sys; print os.path.realpath(sys.argv[1])' $0`
PARENT=`dirname $WHOAMI`

PROJECT=`dirname $PARENT`
PROJECT_NAME=`basename ${PROJECT}`

DATA=$1

if [ "${DATA}" = "" ]
then
    DATA="${PROJECT}/data"
fi

# echo "project ${PROJECT}"
# echo "project name ${PROJECT_NAME}"

PERL=`which perl`

CERTIFIED="${PROJECT}/certified"

if [ ! -f ${PROJECT}/nginx/${PROJECT_NAME}.conf ]
then
    cp ${PROJECT}/nginx/${PROJECT_NAME}.conf.example ${PROJECT}/nginx/${PROJECT_NAME}.conf

    ${PERL} -p -i -e "s!__PROJECT__!${PROJECT}!g" ${PROJECT}/nginx/${PROJECT_NAME}.conf
    ${PERL} -p -i -e "s!__PROJECT_DATA__!${DATA}!g" ${PROJECT}/nginx/${PROJECT_NAME}.conf

    # see also: ubuntu/setup-certified*.sh

    if [ -d ${CERTIFIED} ]
    then
	${PERL} -p -i -e "s!__PROJECT_SSLCERT__!${CERTIFIED}/db/${PROJECT_NAME}.crt!g" ${PROJECT}/nginx/${PROJECT_NAME}.conf
	${PERL} -p -i -e "s!__PROJECT_SSLKEY__!${CERTIFIED}/db/${PROJECT_NAME}.key!g" ${PROJECT}/nginx/${PROJECT_NAME}.conf
    else
	echo "Can not find ${CERTIFIED} directory so you will need to take care of TLS certs yourself..."
    fi

fi

if [ -L /etc/nginx/sites-enabled/default ]
then
    sudo rm /etc/nginx/sites-enabled/default
fi

if [ -f /etc/nginx/sites-enabled/${PROJECT_NAME}.conf ]
then
    sudo rm /etc/nginx/sites-enabled/${PROJECT_NAME}.conf
fi

if [ -L /etc/nginx/sites-enabled/${PROJECT_NAME}.conf ]
then
    sudo rm /etc/nginx/sites-enabled/${PROJECT_NAME}.conf
fi

sudo ln -s ${PROJECT}/nginx/${PROJECT_NAME}.conf /etc/nginx/sites-enabled/${PROJECT_NAME}.conf

sudo /etc/init.d/nginx restart
exit 0
