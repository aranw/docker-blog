# Base system is the LTS version of Ubuntu.
from   base

# Make sure we don't get notifications we can't answer during building.
env    DEBIAN_FRONTEND noninteractive

# An annoying error message keeps appearing unless you do this.
RUN    dpkg-divert --local --rename --add /sbin/initctl
RUN    ln -s /bin/true /sbin/initctl

# Download and install everything from the repos and add geo location database
RUN    apt-get install -y -q software-properties-common
RUN    add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
RUN    add-apt-repository -y ppa:nginx/stable
RUN    apt-get --yes update
RUN    apt-get --yes upgrade --force-yes
RUN    apt-get --yes install git supervisor nginx php5-mcrypt php5-gd php5-mysql mysql-server pwgen wget php5-fpm --force-yes
RUN    mkdir -p /srv/www/; cd /srv/www/; git clone -b master https://github.com/wardrobecms/wardrobe.git blog
RUN    apt-get --yes install php5-cli curl --force-yes
RUN    cd /srv/www/blog;  curl -sS https://getcomposer.org/installer | php; php composer.phar install --prefer-source

# Load in all of our config files.
ADD    ./nginx/nginx.conf /etc/nginx/nginx.conf
ADD    ./nginx/sites-enabled/default /etc/nginx/sites-enabled/default
ADD    ./php5/fpm/php-fpm.conf /etc/php5/fpm/php-fpm.conf
ADD    ./php5/fpm/php.ini /etc/php5/fpm/php.ini
ADD    ./php5/fpm/pool.d/www.conf /etc/php5/fpm/pool.d/www.conf
ADD    ./supervisor/supervisord.conf /etc/supervisor/supervisord.conf
ADD    ./supervisor/conf.d/nginx.conf /etc/supervisor/conf.d/nginx.conf
ADD    ./supervisor/conf.d/mysqld.conf /etc/supervisor/conf.d/mysqld.conf
ADD    ./supervisor/conf.d/php5-fpm.conf /etc/supervisor/conf.d/php5-fpm.conf
ADD    ./mysql/my.cnf /etc/mysql/my.cnf
ADD    ./scripts/start /start

# Fix all permissions
RUN	   chmod +x /start; chown -R www-data:www-data /srv/www/blog

# 80 is for nginx web, /data contains static files and database /start runs it.
EXPOSE 80
VOLUME ["/data"]
CMD    ["/start"]
