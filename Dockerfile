FROM httpd:2.2

# CUWA requires Kerberos libraries from libkrb5-3.
# Also including software additions from former cs/base12 Dockerfile
RUN \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    libkrb5-3 \
    openssh-client \
    ruby \
    unzip \
    vim \
    wget && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Ruby gem installations from former cs/base12 Dockerfile
RUN \
  echo "gem: --no-ri --no-rdoc" > ~/.gemrc && \
  gem install json_pure -v 1.8.1 && \
  gem install puppet -v 3.7.5 && \
  gem install librarian-puppet -v 2.1.0 && \
  gem install hiera-eyaml -v 2.1.0

# Backwards compatibility w/old Ubuntu-based image
COPY ubuntu-compat /root/ubuntu-compat
RUN /root/ubuntu-compat/apply-customizations.sh && \
  rm -rf /root/ubuntu-compat

# Copy files needed for CUWA
COPY conf/cuwebauth.load /etc/apache2/mods-available/cuwebauth.load
COPY lib/mod_cuwebauth.so /usr/lib/apache2/modules/mod_cuwebauth.so

# Create /infra tree for backwards compatibility
RUN mkdir /infra

# Enable modules
RUN a2enmod \
  cuwebauth \
  proxy \
  proxy_http \
  rewrite \
  ssl

# Environment setting from former cs/base12 Dockerfile
ENV HOME /root
WORKDIR /root

# Default ports
EXPOSE 80
EXPOSE 443

# Default Apache launch command
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
