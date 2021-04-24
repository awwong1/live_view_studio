# LiveView Studio

Following the Live View course.

## Development Environment

`elixir --version`
```text
Erlang/OTP 23 [erts-11.1.6] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe]

Elixir 1.11.3 (compiled with Erlang/OTP 23)
```
`node --version`
```text
v14.16.0
```
`docker --version`
```text
Docker version 20.10.6, build 370c289
```

```bash
# fetch Postgres from Docker and mount a local volume for persistence
docker pull postgres:11.11-alpine
mkdir -p ${HOME}/docker/volumes/live_view_studio
docker run \
  --rm \
  --name pg-live-view-studio \
  --env POSTGRES_DB=live_view_studio_dev \
  --env POSTGRES_USER=postgres \
  --env POSTGRES_PASSWORD=postgres \
  --publish 5432:5432 \
  --volume ${HOME}/docker/volumes/live_view_studio:/var/lib/postgresql/data \
  --detach \
  postgres:11.11-alpine

# Fetch elixir dependencies, setup DB, and install Node.js dependencies
mix setup
# Start the application
mix phx.server
```

* [Visual Studio Code](https://code.visualstudio.com/)
    * [jakebecker.elixir-ls](https://marketplace.visualstudio.com/items?itemName=JakeBecker.elixir-ls)
* [Kiex](https://github.com/taylor/kiex)
* [Kerl](https://github.com/kerl/kerl)


## Installation

1. Set up the project:

    ```sh
    mix setup
    ```

2. Fire up the Phoenix endpoint:

    ```sh
    mix phx.server
    ```

3. Visit [`localhost:4000`](http://localhost:4000) from your browser.

## App Generation

This app was generated using:

```sh
mix phx.new live_view_studio --live
```
