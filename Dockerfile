FROM nginx:1.9.11

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/sites-enabled /etc/nginx/conf.d/
COPY dist /usr/share/nginx/html/
