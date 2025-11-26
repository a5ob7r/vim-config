# syntax=docker/dockerfile:1

FROM debian:bookworm-slim

ARG VIM_COMMIT_HASH
ARG MYVIMRC_COMMIT_HASH

RUN <<EOF
	set -eu
	rm -f /etc/apt/apt.conf.d/docker-clean
EOF

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked <<EOF
	set -eu
	apt-get update
	apt-get install --no-install-recommends -y \
		automake \
		build-essential \
		ca-certificates \
		git \
		libncurses-dev \
		;
EOF

ADD https://github.com/vim/vim.git#${VIM_COMMIT_HASH} /vim

WORKDIR /vim

RUN <<EOF
	set -eu
	export CFLAGS='-O2 -march=native'
	./configure \
		--quiet \
		--enable-fail-if-missing \
		--disable-gui \
		;
	make --quiet --jobs
	make --quiet install
EOF

RUN <<EOF
	set -eu
	useradd \
		--shell /bin/bash \
		--create-home \
		a5ob7r \
		;
EOF

USER a5ob7r

ADD --chown=a5ob7r https://github.com/a5ob7r/vim-config.git#${MYVIMRC_COMMIT_HASH} /home/a5ob7r/.vim

WORKDIR /home/a5ob7r
