#!/bin/sh
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer

#EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
#php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
#ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")
#
#if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
#then
#    >&2 echo 'ERROR: Invalid installer signature'
#    rm composer-setup.php
#    exit 1
#fi
#
#php composer-setup.php --quiet --install-dir=/usr/local/bin --filename=composer
#RESULT=$?
#rm composer-setup.php
#exit $RESULT
