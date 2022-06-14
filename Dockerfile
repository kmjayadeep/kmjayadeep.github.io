FROM nginx:1.22.0

WORKDIR /usr/share/nginx/html

COPY assets assets
COPY posts posts
COPY style.css style.css
COPY index.html index.html
