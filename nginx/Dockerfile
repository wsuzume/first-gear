FROM nginx:1.19

RUN apt-get update \
    && apt-get install -y certbot python-certbot-nginx

COPY html /usr/share/nginx/html
COPY conf.d /etc/nginx/conf.d
