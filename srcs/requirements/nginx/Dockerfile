FROM debian:bookworm


# Install nginx and openssl (for TLS)
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*


RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/anguenda.key \
    -out /etc/nginx/ssl/anguenda.crt \
    -subj "/C=MA/ST=Morocco/L=benguerir/O=42/CN=anguenda.42.fr"


COPY conf/nginx.conf /etc/nginx/nginx.conf


EXPOSE 443


CMD ["nginx", "-g", "daemon off;"]