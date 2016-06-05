FROM nginx

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
ADD etc/web-nginx.conf /etc/nginx/sites-enabled/web-nginx.conf
ADD html/ /opt/cloudarmory-web/

EXPOSE 80

CMD ["/usr/sbin/nginx"]
