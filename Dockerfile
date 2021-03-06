# Dockerfile provides minimal tooling and source dependency management for
# any Go projects at Vungle.
#
# Tag: vungle/golang[:<go-semver>]; e.g. vungle/golang:1.5, vungle/golang:1.5.2.
FROM golang:1.13.8

# OUTDIR specifies a directory in which projects can create output files so that
# these output files can be consumed by other processes. Downstream projects can
# choose to mount OUTDIR to a volume directly or create a directory and perform
# `docker cp ...` later.
ENV OUTDIR /out

##########################
# Testing and Tooling
#
# NOTE: For testing and tooling binaries that are actually built with Go, we
# want to only retain its binaries to avoid unexpected source dependencies bleed
# into the project source code.
##########################
RUN go get -u \
        github.com/jstemmer/go-junit-report \
        github.com/t-yuki/gocover-cobertura \
        github.com/wadey/gocovmerge \
        golang.org/x/lint/golint \
        golang.org/x/tools/cmd/goimports \
        github.com/golang/dep/cmd/dep \
    && rm -rf $GOPATH/src/* && rm -rf $GOPATH/pkg/*

ENV GLIDE_VERSION v0.12.3

##########################
# Dependency Management
##########################
# Install Glide.
RUN mkdir -p /tmp && cd /tmp \
    && curl -fsSL https://github.com/Masterminds/glide/releases/download/$GLIDE_VERSION/glide-$GLIDE_VERSION-linux-amd64.tar.gz \
            -o glide.tar.gz \
    && tar -xzf glide.tar.gz \
    && mv linux-amd64/glide /usr/local/bin/glide \
    && rm -rf /tmp/*

# TODO: Benchmark report tools.

##########################
# Testing scripts
##########################
COPY files/report.sh /usr/local/bin/report.sh
COPY files/coverage.sh /usr/local/bin/coverage.sh

##########################
# Code Analysis scripts
##########################
COPY files/lint.sh /usr/local/bin/lint.sh
