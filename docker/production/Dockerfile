FROM approov/quickstart-elixir-phoenix

ARG GIT_CHECKOUT_TO=master
ARG SERVER_NAME=unprotected-server
ARG GIT_CLONE_URL=https://github.com/approov/quickstart-elixir-phoenix-absinthe-graphql-token-check.git

ENV RELEASE_PATH="${CONTAINER_HOME}"/phoenix_release

RUN \
  SERVER_PATH=src/"${SERVER_NAME}"/todo && \
  GIT_CLONE_PATH="${CONTAINER_HOME}"/repo && \
  git clone "${GIT_CLONE_URL}" "${GIT_CLONE_PATH}" && \
  cd "${GIT_CLONE_PATH}" && \
  git checkout "${GIT_CHECKOUT_TO}" && \
  ls -al && \
  cd "${SERVER_PATH}" && \

  # The real values must be provided when starting the release
  # Needed to allow to load from env the variables that raise when missing in releases.exs
  export $(grep -v '^#' .env.production.example | xargs -0) && \

  mix deps.get --only prod && \
  mix compile && \
  MIX_ENV=prod mix release --path "${RELEASE_PATH}" && \

  cd "${RELEASE_PATH}" && \

  rm -rf "${GIT_CLONE_PATH}"

WORKDIR "${RELEASE_PATH}"

RUN ls -al

CMD ["bin/todo", "start"]
