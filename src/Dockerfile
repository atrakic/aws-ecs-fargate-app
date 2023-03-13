FROM nginxinc/nginx-unprivileged:stable AS final
WORKDIR /usr/share/nginx/html
COPY ./default.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html
EXPOSE 8080
# ENTRYPOINT ["nginx", "-g", "daemon off;"]
