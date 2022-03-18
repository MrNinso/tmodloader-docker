FROM rfvgyhn/tmodloader:v0.11.7.8 as build

FROM mono:6.12.0.122

ARG TMOD_VERSION=0.11.8.8

WORKDIR /terraria-server

COPY --from=build /usr/local/bin/inject /usr/local/bin/inject
COPY --from=build /terraria-server /terraria-server
COPY ./entrypoint.sh /terraria-server

RUN curl -SL "https://github.com/tModLoader/tModLoader/releases/download/v${TMOD_VERSION}/tModLoader.Linux.v${TMOD_VERSION}.tar.gz" | tar -xvz &&\
    rm -r lib tModLoader.bin.x86 tModLoaderServer.bin.x86 &&\
    chmod u+x tModLoaderServer &&\
    apt-get update &&\
    apt-get install procps tmux cron -y &&\
    ln -s ${HOME}/.local/share/Terraria/ /terraria &&\
    mkdir sys &&\
    mv System*.dll* sys &&\
    mv WindowsBase.dll sys &&\
    mv Mono*.dll sys

EXPOSE 7777
ENV TMOD_SHUTDOWN_MSG="Shutting down!"
ENV TMOD_AUTOSAVE_INTERVAL="*/10 * * * *"

RUN chmod +x entrypoint.sh /usr/local/bin/inject

ENTRYPOINT [ "/terraria-server/entrypoint.sh" ]
