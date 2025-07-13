FROM dart:3.8 as build


# Flutter SDK の安定版インストール
RUN git clone https://github.com/flutter/flutter.git /flutter -b stable
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

WORKDIR /app
COPY . .

EXPOSE 8080