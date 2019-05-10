[ -f .env ] || touch .env

source .env

if [ "$SECRET_KEY" = "" ]; then
    SECRET_KEY=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 50`
    echo "SECRET_KEY=$SECRET_KEY" >> .env
    echo "SECRET_KEY: $SECRET_KEY"
else
    echo "SECRET_KEY: $SECRET_KEY"
fi

if [ "$BOOTSTRAP_TOKEN" = "" ]; then
    BOOTSTRAP_TOKEN=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 16`
    echo "BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN" >> .env
    echo "BOOTSTRAP_TOKEN: $BOOTSTRAP_TOKEN"
else
    echo "BOOTSTRAP_TOKEN: $BOOTSTRAP_TOKEN"
fi

if [ "$MYSQL_ROOT_PASSWORD" = "" ]; then
    MYSQL_ROOT_PASSWORD=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 20`
    echo "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" >> .env
    echo "MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD"
else
    echo "MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD"
fi

if [ "$MYSQL_PASSWORD" = "" ]; then
    MYSQL_PASSWORD=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 20`
    echo "MYSQL_PASSWORD=$MYSQL_PASSWORD" >> .env
    echo "MYSQL_PASSWORD: $MYSQL_PASSWORD"
else
    echo "MYSQL_PASSWORD: $MYSQL_PASSWORD"
fi

if [ "$REDIS_PASSWORD" = "" ]; then
    REDIS_PASSWORD=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 20`
    echo "REDIS_PASSWORD=$REDIS_PASSWORD" >> .env
    echo "REDIS_PASSWORD: $REDIS_PASSWORD"
else
    echo "REDIS_PASSWORD: $REDIS_PASSWORD"
fi

