FROM node:14 AS starter
FROM python:3.9 AS builder

COPY --from=starter /usr/local/bin /usr/local/bin
COPY --from=starter /usr/local/lib/node_modules/npm /usr/local/lib/node_modules/npm

ARG AMP_DOC_TOKEN

ENV APM_DOC_TOKEN=${AMP_DOC_TOKEN}
ENV APP_ENV=production
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install `--no-install-recommends` \
    curl \
    build-essential \
    git \
    libyaml-dev \
    parallel -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Bundle app source
COPY . .

# Install dependencies to create builder image
RUN npm install
RUN npx gulp buildPrepare
RUN npx gulp unpackArtifacts
RUN pip install --upgrade pip
RUN echo "Cython<3" > cython_constraint.txt
RUN PIP_CONSTRAINT=cython_constraint.txt pip install grow --upgrade-strategy eager
# RUN echo "/********** BUILDER IMAGE READY **********/"

# Build language pages
FROM builder AS lanen
RUN npx gulp buildPages --locales 'en'
RUN npx gulp buildFinalize
# RUN echo "/********** EN IMAGE READY **********/"

# FROM builder AS lande
# RUN npx gulp buildPages --locales 'de'
# RUN npx gulp buildFinalize
# # RUN echo "/********** DE IMAGE READY **********/"

FROM builder AS lanfr
RUN npx gulp buildPages --locales 'fr'
RUN npx gulp buildFinalize
# RUN echo "/********** FR IMAGE READY **********/"

# FROM builder AS lanar
# RUN npx gulp buildPages --locales 'ar'
# RUN npx gulp buildFinalize
# # RUN echo "/********** AR IMAGE READY **********/"

FROM builder AS lanes
RUN npx gulp buildPages --locales 'es'
RUN npx gulp buildFinalize
# RUN echo "/********** ES IMAGE READY **********/"

# FROM builder AS lanit
# RUN npx gulp buildPages --locales 'it'
# RUN npx gulp buildFinalize
# # RUN echo "/********** IT IMAGE READY **********/"

# FROM builder AS lanid
# RUN npx gulp buildPages --locales 'id'
# RUN npx gulp buildFinalize
# # RUN echo "/********** ID IMAGE READY **********/"

# FROM builder AS lanja
# RUN npx gulp buildPages --locales 'ja'
# RUN npx gulp buildFinalize
# # RUN echo "/********** JA IMAGE READY **********/"

# FROM builder AS lanko
# RUN npx gulp buildPages --locales 'ko'
# RUN npx gulp buildFinalize
# # RUN echo "/********** KO IMAGE READY **********/"

# FROM builder AS lanbr
# RUN npx gulp buildPages --locales 'pt_BR'
# RUN npx gulp buildFinalize
# # RUN echo "/********** pt_BR IMAGE READY **********/"

# FROM builder AS lanru
# RUN npx gulp buildPages --locales 'ru'
# RUN npx gulp buildFinalize
# # RUN echo "/********** RU IMAGE READY **********/"

# FROM builder AS lantr
# RUN npx gulp buildPages --locales 'tr'
# RUN npx gulp buildFinalize
# # RUN echo "/********** TR IMAGE READY **********/"

# FROM builder AS lancn
# RUN npx gulp buildPages --locales 'zh_CN'
# RUN npx gulp buildFinalize
# # RUN echo "/********** zh_CN IMAGE READY **********/"

# FROM builder AS lanpl
# RUN npx gulp buildPages --locales 'pl'
# RUN npx gulp buildFinalize
# # RUN echo "/********** pl IMAGE READY **********/"

# FROM builder AS lanvi
# RUN npx gulp buildPages --locales 'vi'
# RUN npx gulp buildFinalize
# # RUN echo "/********** vi IMAGE READY **********/"

# Create final compact image and copy build artifacts
FROM httpd:2.4 AS FINAL
COPY --from=lanen /app/dist/pages/ /usr/local/apache2/htdocs/
# COPY --from=lande /app/dist/pages/ /usr/local/apache2/htdocs/
COPY --from=lanfr /app/dist/pages/ /usr/local/apache2/htdocs/
# COPY --from=lanar /app/dist/pages/ /usr/local/apache2/htdocs/
COPY --from=lanes /app/dist/pages/ /usr/local/apache2/htdocs/
# COPY --from=lanit /app/dist/pages/ /usr/local/apache2/htdocs/
# COPY --from=lanid /app/dist/pages/ /usr/local/apache2/htdocs/
# COPY --from=lanja /app/dist/pages/ /usr/local/apache2/htdocs/
# COPY --from=lanko /app/dist/pages/ /usr/local/apache2/htdocs/
# COPY --from=lanbr /app/dist/pages/ /usr/local/apache2/htdocs/
# COPY --from=lanru /app/dist/pages/ /usr/local/apache2/htdocs/
# COPY --from=lantr /app/dist/pages/ /usr/local/apache2/htdocs/
# COPY --from=lancn /app/dist/pages/ /usr/local/apache2/htdocs/
# COPY --from=lanpl /app/dist/pages/ /usr/local/apache2/htdocs/
# COPY --from=lanvi /app/dist/pages/ /usr/local/apache2/htdocs/

RUN mkdir /usr/local/apache2/htdocs/playground
COPY --from=lanen /app/dist/playground/ /usr/local/apache2/htdocs/playground/
# COPY --from=lande /app/dist/playground/ /usr/local/apache2/htdocs/playground/
COPY --from=lanfr /app/dist/playground/ /usr/local/apache2/htdocs/playground/
# COPY --from=lanar /app/dist/playground/ /usr/local/apache2/htdocs/playground/
COPY --from=lanes /app/dist/playground/ /usr/local/apache2/htdocs/playground/
# COPY --from=lanit /app/dist/playground/ /usr/local/apache2/htdocs/playground/
# COPY --from=lanid /app/dist/playground/ /usr/local/apache2/htdocs/playground/
# COPY --from=lanja /app/dist/playground/ /usr/local/apache2/htdocs/playground/
# COPY --from=lanko /app/dist/playground/ /usr/local/apache2/htdocs/playground/
# COPY --from=lanbr /app/dist/playground/ /usr/local/apache2/htdocs/playground/
# COPY --from=lanru /app/dist/playground/ /usr/local/apache2/htdocs/playground/
# COPY --from=lantr /app/dist/playground/ /usr/local/apache2/htdocs/playground/
# COPY --from=lancn /app/dist/playground/ /usr/local/apache2/htdocs/playground/
# COPY --from=lanpl /app/dist/playground/ /usr/local/apache2/htdocs/playground/
# COPY --from=lanvi /app/dist/playground/ /usr/local/apache2/htdocs/playground/