FROM node:18-bullseye-slim AS client-build

WORKDIR /build
COPY package.json yarn.lock .yarnrc.yml /build/
COPY .yarn/ /build/.yarn/
RUN yarn install

COPY . /build
RUN yarn run build

FROM rust:1-bullseye as server-build

RUN apt-get update && \
  apt-get -y --no-install-recommends install software-properties-common && \
  add-apt-repository "deb http://httpredir.debian.org/debian sid main" && \
  apt-get update && \
  apt-get -t sid install -y --no-install-recommends libdav1d-dev libclang-dev

WORKDIR /build
COPY Cargo.toml .
RUN mkdir -p src && echo 'fn main() {}' > dummy.rs
RUN sed -i 's#src/main.rs#dummy.rs#' Cargo.toml
RUN cargo build --release
RUN sed -i 's#dummy.rs#src/main.rs#' Cargo.toml

COPY . /build
COPY --from=client-build /build/public/ /build/public/
RUN cargo build --release

FROM debian:bullseye-slim
RUN apt-get update && \
  apt-get -y --no-install-recommends install software-properties-common && \
  add-apt-repository "deb http://httpredir.debian.org/debian sid main" && \
  apt-get update && \
  apt-get -t sid install -y --no-install-recommends dav1d

COPY --from=server-build /build/target/release/union_bug /usr/bin/union_bug
ENV RUST_LOG debug
EXPOSE 3928
WORKDIR /
CMD /usr/bin/union_bug
