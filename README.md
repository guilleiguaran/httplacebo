# HTTPlacebo

HTTP client mocking tool for Elixir, based on [HTTPotion](https://github.com/myfreeweb/httpotion), [HTTPoison](https://github.com/edgurgel/httpoison) and inspired in [HTTPretty](https://github.com/gabrielfalcao/HTTPretty).

## Installation

  1. Add httplacebo to your list of dependencies in `mix.exs`:

        def deps do
          [{:httplacebo, "~> 0.0.1"}]
        end

  2. Ensure httplacebo is started before your application:

        def application do
          [applications: [:httplacebo]]
        end

## Usage

```iex
iex> HTTPlacebo.start
iex> HTTPlacebo.register_uri(:get, "http://localhost:3000/posts/1", 200, ~s({"post": {"title": "First Post"}}), [{"Content-Type", "application/json"}])
iex> HTTPlacebo.get! "http://localhost:3000/posts/1"
%HTTPlacebo.Response{
  body: "{\"post\": {\"title\": \"First Post\"}}",
  headers: [{"Content-Type", "application/json"}],
  status_code: 200
}
iex> HTTPlacebo.get! "http://localhost:3000/users"
%HTTPoison.Response{body: "Not Found", status_code: 404}
iex> HTTPlacebo.get "http://localhost:3000/users"
{:ok, %HTTPoison.Response{body: "Not Found", status_code: 404}}
```

You can also easily pattern match on the `HTTPlacebo.Response` struct:

```elixir
case HTTPlacebo.get(url) do
  {:ok, %HTTPlacebo.Response{status_code: 200, body: body}} ->
    IO.puts body
  {:ok, %HTTPlacebo.Response{status_code: 404}} ->
    IO.puts "Not found :("
end
```

### Using with existing applications

You can use HTTPlacebo as replacement for HTTPotion/HTTPoison instead of mocking as described in the [Mocks and Explicit contracts](http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/) post by Jose Valim.

```elixir
defmodule MyBlog.Post do
  @http_mod Application.get_env(:my_app, :http_mod)

  def get(id) do
    # ...
    @http_mod.get("http://myblog.com/posts/" <> id)
    # ...
  end
end
```

And now we can configure it per environment as:

```elixir
# In config/dev.exs
config :my_app, :http_mod, HTTPoison

# In config/test.exs
config :my_app, :http_mod, HTTPlacebo
```

## License

    Copyright © 2016 Guillermo Iguaran <guilleiguaran@gmail.com>

    This work is free. You can redistribute it and/or modify it under the
    terms of the MIT License. See the LICENSE file for more details.
