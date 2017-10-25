FROM quay.io/kwiksand/cryptocoin-base:latest

RUN useradd -m chaincoin

ENV DAEMON_RELEASE="v0.9.3.2"
ENV E_COIN_CURRENCY="chaincoin"
ENV E_COIN_SYMBOL="CHC"
ENV E_COIN_DAEMON="/usr/bin/chaincoin-cli -conf=/home/chaincoin/.chaincoin/chaincoin.conf"
ENV E_GET_BLOCKCOUNT='/usr/bin/curl -s http://104.238.153.140:3001/api/getblockcount' 
ENV E_MASTERNODE_CONF="chaincoinnode"
ENV CHAINCOIN_DATA=/home/chaincoin/.chaincoin

USER chaincoin

RUN cd /home/chaincoin && \
    mkdir /home/chaincoin/bin && \
    mkdir .ssh && \
    chmod 700 .ssh && \
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts && \
    ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts && \
    git clone --branch $DAEMON_RELEASE https://github.com/chaincoin/chaincoin.git chaincoind && \
    cd /home/chaincoin/chaincoind && \
    ./autogen.sh && \
    ./configure LDFLAGS="-L/home/chaincoin/db4/lib/" CPPFLAGS="-I/home/chaincoin/db4/include/" && \
    make && \
    strip src/chaincoind && \
    strip src/chaincoin-cli && \
    strip src/chaincoin-tx && \
    mv src/chaincoind src/chaincoin-cli src/chaincoin-tx /home/chaincoin/bin && \
    rm -rf /home/chaincoin/chaincoind
    
EXPOSE 4854 4855

#VOLUME ["/home/chaincoin/.chaincoin"]

USER root

COPY docker-entrypoint.sh /entrypoint.sh

RUN chmod 777 /entrypoint.sh && \
    echo "\n# Some aliases to make the chaincoin clients/tools easier to access\nalias chaincoind='/usr/bin/chaincoind -conf=/home/chaincoin/.chaincoin/chaincoin.conf'\nalias chaincoin-cli='/usr/bin/chaincoin-cli -conf=/home/chaincoin/.chaincoin/chaincoin.conf'\n" >> /etc/bash.bashrc && \
    echo "Chaincoin (CHC) Cryptocoin Daemon\n\nUsage:\n chaincoin-cli help - List help options\n chaincoin-cli listtransactions - List Transactions\n\n" > /etc/motd && \
    chmod 755 /home/chaincoin/bin/chaincoind && \
    chmod 755 /home/chaincoin/bin/chaincoin-cli && \
    chmod 755 /home/chaincoin/bin/chaincoin-tx && \
    mv /home/chaincoin/bin/chaincoind /usr/bin/chaincoind && \
    mv /home/chaincoin/bin/chaincoin-cli /usr/bin/chaincoin-cli && \
    mv /home/chaincoin/bin/chaincoin-tx /usr/bin/chaincoin-tx 

COPY node-status.sh /usr/bin/node-status

ENTRYPOINT ["/entrypoint.sh"]

CMD ["chaincoind"]
