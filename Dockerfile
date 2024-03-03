FROM node:14 AS STARTER

FROM python:3.9 AS BUILDER

COPY --from=STARTER /usr/local/bin /usr/local/bin
COPY --from=STARTER /usr/local/lib/node_modules/npm /usr/local/lib/node_modules/npm

ARG AMP_DOC_TOKEN

ENV APM_DOC_TOKEN=${AMP_DOC_TOKEN}
ENV APP_ENV=production
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install \
    curl \
    build-essential \
    git \
    libyaml-dev \
    parallel -y

WORKDIR /app
COPY . .

RUN npm install
RUN npx gulp buildPrepare
RUN npx gulp unpackArtifacts
RUN pip install --upgrade pip
#RUN pip install pyyaml==6.0.1
#RUN echo "cython<3" > /tmp/requirements.txt
#RUN pip freeze > requirements.txt
#RUN PIP_CONSTRAINT=/tmp/constraint.txt pip install -r /tmp/requirements.txt
#RUN pip install "cython<3.0.0" wheel && pip install --no-build-isolation pyyaml==5.3.1
#RUN pip install "cython<3.0.0" wheel
#RUN pip install "pyyaml==5.4.1" --no-build-isolation
#RUN pip freeze > requirements.txt
#RUN pip install -r requirements.txt
#RUN PIP_CONSTRAINT=/tmp/constraint.txt pip install grow --upgrade-strategy eager
#RUN pip install "cython<3.0.0" wheel && pip install --no-build-isolation pyyaml==5.3.1
#RUN PIP_REQUIREMENTS=requirements.txt pip install grow --upgrade-strategy eager
RUN pip install grow --upgrade-strategy eager

#Build Languages - Uncomment languages that you want to build 
RUN npx gulp buildPages --locales 'en'
#RUN npx gulp buildPages --locales 'de'
#RUN npx gulp buildPages --locales 'fr'
#RUN npx gulp buildPages --locales 'ar'
#RUN npx gulp buildPages --locales 'es'
#RUN npx gulp buildPages --locales 'it'
#RUN npx gulp buildPages --locales 'id'
#RUN npx gulp buildPages --locales 'ja'
#RUN npx gulp buildPages --locales 'ko'
#RUN npx gulp buildPages --locales 'pt_BR'
#RUN npx gulp buildPages --locales 'ru'
#RUN npx gulp buildPages --locales 'zh_CN'
#RUN npx gulp buildPages --locales 'pi'
#RUN npx gulp buildPages --locales 'vi'
#RUN npx gulp buildPages --locales 'en'

RUN npx gulp buildFinalize

FROM httpd:2.4 AS FINAL

COPY --from=BUILDER /app/dist/pages/ /usr/local/apache2/htdocs/
RUN mkdir /usr/local/apache2/htdocs/playground
COPY --from=BUILDER /app/dist/playground/ /usr/local/apache2/htdocs/playground/

# # Create app directory
# WORKDIR /usr/src/app

# # Install dependencies
# RUN apk --no-cache add g++ gcc libgcc libstdc++ linux-headers make python3 tini
# RUN ln -s /usr/bin/python3 /usr/bin/python
# RUN npm install --quiet node-gyp -g
# # Add Tini
# ENTRYPOINT ["/sbin/tini", "--"]

# # Install app dependencies
# COPY package.json .
# COPY package-lock.json .
# RUN npm ci --only=production

# # Make sure to get latest
# ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache

# # Bundle app source
# COPY . .

# EXPOSE 80 8080
# WORKDIR "platform"
# ENV NODE_ENV=production
# CMD ["node", "serve.js"]
