FROM wordpress:latest

RUN docker-php-ext-install pdo pdo_mysql
RUN docker-php-ext-enable pdo pdo_mysql

RUN  apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*

RUN  apt-get update -y && \
     apt-get upgrade -y && \
     apt-get dist-upgrade -y && \
     apt-get -y autoremove && \
     apt-get clean

RUN apt-get install zip unzip && \ 
    rm -rf /var/lib/apt/lists/*

# install localisation
RUN apt-get update && \
    # locales
    apt-get install -y locales

# enable localisation and generates localisation files
RUN sed -i -e 's/# cs_CZ.UTF-8/cs_CZ.UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# cs_CZ.UTF-8/cs_CZ.UTF-8/' /etc/locale.gen && \
    locale-gen

RUN echo "cs_CZ.UTF-8 UTF-8" >> /etc/locale.gen

# Imstall the locale
RUN apt-get update -y && \
    apt-get install -y locales locales-all

# Set the locale
RUN sed -i '/cs_CZ.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG cs_CZ.UTF-8
ENV LANGUAGE cs_CZ.UTF-8
ENV LC_ALL cs_CZ.UTF-8

# fetch plugins
COPY plugins.list /tmp/plugins.list
RUN cd /var/www/html/wp-content/plugins && rm -rfv * && \
    # Strip comments from plugins.list file (https://unix.stackexchange.com/a/157619/352972) and then install each plugin:
    for plugin in $(sed '/^[[:blank:]]*#/d;s/#.*//' /tmp/plugins.list); do \
        # The for loop swallows any non-zero exit code, we need to exit explicitly on failure:
        echo "Installing plugin $plugin" && \
        wget -q $plugin -O temp.zip && \
        unzip -q temp.zip && \
        rm temp.zip || exit 1; \
    done

# set correct rights for plugins
RUN chown -R www-data:www-data /var/www/html/wp-content/plugins
