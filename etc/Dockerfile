FROM nginx

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
ADD etc/web-nginx.conf /etc/nginx/conf.d/web-nginx.conf
ADD html/ /opt/cloudarmory-web/

EXPOSE 80

CMD ["/usr/sbin/nginx"]
