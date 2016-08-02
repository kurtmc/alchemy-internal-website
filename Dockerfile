FROM fedora

ADD ./ /var/alchemy

RUN /var/alchemy/init-dev.sh

RUN rm -rf /var/alchemy
