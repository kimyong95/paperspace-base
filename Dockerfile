# syntax=docker/dockerfile:1.3-labs
FROM paperspace/gradient-base:pt112-tf29-jax0314-py39-20220803
ARG PYTHON_VERSION=3.10.8

# Common packages
RUN apt update && \
    apt install -y wget curl git sudo nano software-properties-common tmux openssh-server

# Setup User
RUN useradd -ms /bin/bash paperspace
RUN echo 'paperspace ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN mkdir -p /home/paperspace/.ssh
RUN mkdir -p /run/sshd
USER paperspace

# Tmux setting
RUN cat <<-EOF >> $HOME/.tmux.conf 
	set-option -g mouse on
EOF

# Install Python
RUN sudo apt install -y \
    build-essential ca-certificates \
    libbz2-dev zlib1g-dev libffi-dev libncursesw5-dev libreadline-dev libsqlite3-dev liblzma-dev libssl-dev libhdf5-dev
RUN curl https://pyenv.run | bash
RUN cat <<-EOF >> $HOME/.bashrc
	export PATH="$HOME/.pyenv/bin:\$PATH"
	eval "\$(pyenv init -)"
EOF
RUN /bin/bash -ic "source ~/.bashrc; pyenv install $PYTHON_VERSION; pyenv global $PYTHON_VERSION"

# Install Poetry
RUN /bin/bash -ic "curl -sSL https://install.python-poetry.org | python3 -"
RUN cat <<-EOF >> $HOME/.bashrc
	export PATH="$HOME/.local/bin:\$PATH"
EOF
RUN /bin/bash -ic "poetry config virtualenvs.in-project true"

# Install Cloudflared
RUN curl -L --output /tmp/cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && \
    sudo apt install /tmp/cloudflared.deb && \
    rm /tmp/cloudflared.deb

ENV PYTHONPATH=.
WORKDIR /notebooks