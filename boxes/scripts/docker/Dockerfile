FROM mcr.microsoft.com/azure-cli:latest
RUN pip install --upgrade pip
# RUN apt update - --no-install-recommends && apt update -y
RUN az config set extension.use_dynamic_install=yes_without_prompt
RUN az extension add --upgrade -n storage-preview
RUN wget https://curl.se/download/curl-7.58.0.zip
RUN unzip curl-7.58.0.zip
RUN cd curl-7.58.0 && ./configure --prefix=`pwd`/curl
RUN cd curl-7.58.0 && make && make install
RUN rm /usr/bin/curl
RUN ln -s  /curl-7.58.0/curl/bin/curl /usr/bin/curl
COPY *.sh /scripts/
CMD sh

