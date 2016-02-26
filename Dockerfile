# Specifing the base image
FROM     debian:8.3

# Maintainer
MAINTAINER      "Vaibhav Todi"       <vaibhav@deeproot.in>

# Specifing the Label
LABEL    Description="Docker Image where base is Debian-8.3 and along with it LAMP Server is installed"     \
         Company="Deeproot Linux (p) ltd"                                                                   \
         Version="1.0"

# Setting the environment & Working Directory
ENV      home           /root
WORKDIR  $home

# Updating the base system & Installing some packages
RUN      apt-get  update                                                                                                         \
     &&  "echo mysql-server-5.5 mysql-server/root_password password deeproot@123" | debconf-set-selections                       \
     &&  "echo mysql-server-5.5 mysql-server/root_password_again password deeproot@123" | debconf-set-selections                 \
     &&  DEBIAN_FRONTEND=noninteractive apt-get  install  -y  apache2 php5 php5-mysql mysql-server-5.5 mysql-client-5.5          \
                                                              openssh-server libapache2-mod-php5 nano wget curl runit

# Creating the Directories
RUN      mkdir    -p       /var/run/apache2     \
     &&  mkdir    -p       /var/run/mysqld      \
     &&  mkdir    -p       /var/lock/apache2    \
     &&  mkdir    -p       /var/run/sshd        \
     &&  mkdir    -p       /etc/sv/apache2      \
     &&  mkdir    -p       /etc/sv/sshd         \
     &&  mkdir    -p       /etc/sv/mysql-server

# Setting up the Apache2 environment
ENV      APACHE_RUN_USER=www-data               \
         APACHE_RUN_GROUP=www-data              \
         APACHE_LOG_DIR=/var/log/apache2        \
         APACHE_PID_FILE=/var/run/apache2.pid   \
         APACHE_RUN_DIR=/var/run/apache2        \
         APACHE_LOCK_DIR=/var/lock/apache2      \
         APACHE_LOG_DIR=/var/log/apache2

# Setting up SSHD
RUN      echo "root:docker@covert" | chpasswd                                                                                 \
     &&  sed  -i   's/PermitRootLogin without-password/PermitRootLogin yes/'  /etc/ssh/sshd_config                            \
     &&  sed  -i   's/#AuthorizedKeysFile/AuthorizedKeysFile/'                /etc/ssh/sshd_config

# Copying the RUNIT Files for running the services
COPY     apache2         /etc/sv/apache2
COPY     mysql-server    /etc/sv/mysql-server
COPY     sshd            /etc/sv/sshd

# Copying the entrypoint.sh
COPY     entrypoint.sh   /entrypoint.sh

# Clearing the Docker image
RUN      apt-get   -y    clean                                                                                               \
     &&  rm        -rf   /var/lib/apt/lists/*

# Exposing Ports
EXPOSE   80  22  443  3306

# Mounting Volumes
VOLUME   ["/var/lib/mysql", "/var/www"]

# CMD instruction
CMD      ["/entrypoint.sh"]
