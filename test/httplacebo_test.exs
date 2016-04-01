defmodule HTTPlaceboTest do
  use ExUnit.Case, async: true

  setup do
    HTTPlacebo.start
    :ok
  end

  test "get" do
    HTTPlacebo.register_uri(:get, "http://localhost:3000/hello", [body: ~s(Hello, world)])
    assert_response HTTPlacebo.get("localhost:3000/hello"), fn(response) ->
      assert response.body == "Hello, world"
    end
  end

  test "get with params" do
    HTTPlacebo.register_uri(:get, "http://localhost:3000/hello?who=guille", [body: ~s(Hello, guille)])
    assert_response HTTPlacebo.get("localhost:3000/hello", [], params: %{who: "guille"}), fn(response) ->
      assert response.body == "Hello, guille"
    end
  end

  test "head" do
    HTTPlacebo.register_uri(:head, "http://localhost:3000/head")
    assert_response HTTPlacebo.head("localhost:3000/head")
  end

  test "post charlist body" do
    HTTPlacebo.register_uri(:post, "http://localhost:3000/post")
    assert_response HTTPlacebo.post("localhost:3000/post", 'test')
  end

  test "post binary body" do
    { :ok, file } = File.read("LICENSE")
    HTTPlacebo.register_uri(:post, "http://localhost:3000/post")
    assert_response HTTPlacebo.post("localhost:3000/post", file)
  end

  test "post form data" do
    HTTPlacebo.register_uri(:post, "http://localhost:3000/post")
    assert_response HTTPlacebo.post("localhost:3000/post", {:form, [key: "value"]}, %{"Content-type" => "application/x-www-form-urlencoded"})
  end

  test "put" do
    HTTPlacebo.register_uri(:put, "http://localhost:3000/put")
    assert_response HTTPlacebo.put("localhost:3000/put", "test")
  end

  test "patch" do
    HTTPlacebo.register_uri(:patch, "http://localhost:3000/patch")
    assert_response HTTPlacebo.patch("localhost:3000/patch", "test")
  end

  test "delete" do
    HTTPlacebo.register_uri(:delete, "http://localhost:3000/delete")
    assert_response HTTPlacebo.delete("localhost:3000/delete")
  end

  test "options" do
    HTTPlacebo.register_uri(:options, "http://localhost:3000/options")
    assert_response HTTPlacebo.options("localhost:3000/options")
  end

  test "explicit http scheme" do
    HTTPlacebo.register_uri(:get, "http://localhost:3000/get")
    assert_response HTTPlacebo.get("http://localhost:3000/get")
  end

  test "https scheme" do
    HTTPlacebo.register_uri(:get, "https://localhost:3000/get")
    assert_response HTTPlacebo.get("https://localhost:3000/get")
  end

  test "char list URL" do
    HTTPlacebo.register_uri(:get, "http://localhost:3000/get")
    assert_response HTTPlacebo.get('localhost:3000/get')
  end

  test "missing page" do
    assert HTTPlacebo.get "localhost:3000/404" == { :ok, %HTTPlacebo.Response{status_code: 404, body: "Not Found"} }
  end

  defp assert_response({:ok, response}, function \\ nil) do
    assert is_list(response.headers)
    assert response.status_code == 200
    assert is_binary(response.body)

    unless function == nil, do: function.(response)
  end
end
