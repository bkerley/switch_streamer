FROM crystallang/crystal:0.35.1

RUN mkdir /app
WORKDIR /app
RUN addgroup --gid 1000 app && \
        adduser --uid 1000 --ingroup app app && \
        chown -R app:app /app
COPY --chown=app:app . /app
RUN shards install && shards build switch_streamer
CMD ./app --port ${PORT}
