FROM bitwalker/alpine-elixir-phoenix:latest

# Set exposed ports
EXPOSE 4000
ENV PORT=4000 MIX_ENV=prod

# Cache elixir deps
RUN apk add --no-cache inotify-tools \
    && mix local.hex --force \
    && mix local.rebar --force \
    && mix archive.install --force hex phx_new

USER default

CMD ["mix", "phx.server"]
