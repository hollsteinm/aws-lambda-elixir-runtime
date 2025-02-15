# Copyright 2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

defmodule Mix.Tasks.Bootstrap do
  @moduledoc """
  Generate a bootstrap script for the project in the release directory.
  This task will fail if it's run before `mix release`.
  """

  use Mix.Task

  @runtime_libs "aws_lambda_elixir_runtime-0.1.1/priv"

  @shortdoc "Generate a bootstrap script for the project"
  def run(_) do
    name =
      Mix.Project.config()
      |> Keyword.fetch!(:app)
      |> to_string

    path = "_build/#{Mix.env()}/rel/#{name}/bootstrap"

    Mix.Generator.create_file(path, bootstrap(name))
    File.chmod!(path, 0o777)
  end

  # The bootstrap script contents
  defp bootstrap(app) when is_binary(app) do
    """
    \#!/bin/bash

    set -x

    BASE=$(dirname "$0")
    EXE=$BASE/bin/#{app}

    HOME=/tmp
    export HOME

    \# So that distillery doesn't try to write any files
    export RELEASE_READ_ONLY=true

    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BASE/lib/#{@runtime_libs}

    $EXE foreground
    """
  end
end
