defmodule HTTPlacebo.Base do
  alias HTTPlacebo.Response

  defmacro __using__(_) do
    quote do
      @type headers :: [{binary, binary}] | %{binary => binary}
      @type body :: binary | {:form, [{atom, any}]} | {:file, binary}

      def start() do
        :ets.new(:uris_registry, [:named_table, :public])
        {:ok, []}
      end

      def register_uri(method, url, args \\ []) do
        body = Keyword.get(args, :body, "")
        headers = Keyword.get(args, :headers, [])
        status_code = Keyword.get(args, :status_code, 200)
        options = Keyword.get(args, :options, [])

        if Keyword.has_key?(options, :params) do
          url = url <> "?" <> URI.encode_query(options[:params])
        end

        :ets.insert(:uris_registry, {{method, url}, {status_code, headers, body}})
        {:ok, method, url}
      end

      defp process_url(url) do
        HTTPlacebo.Base.default_process_url(url)
      end

      defp process_request_body(body), do: body

      defp process_response_body(body), do: body

      defp process_request_headers(headers) when is_map(headers) do
        Enum.into(headers, [])
      end
      defp process_request_headers(headers), do: headers

      defp process_response_chunk(chunk), do: chunk

      defp process_headers(headers), do: headers

      defp process_status_code(status_code), do: status_code

      @spec request(atom, binary, body, headers, Keyword.t) :: {:ok, Response.t}
      def request(method, url, body \\ "", headers \\ [], options \\ []) do
        if Keyword.has_key?(options, :params) do
          url = url <> "?" <> URI.encode_query(options[:params])
        end
        url = process_url(to_string(url))
        body = process_request_body(body)
        headers = process_request_headers(headers)
        HTTPlacebo.Base.request(method, url, &process_status_code/1, &process_headers/1, &process_response_body/1)
      end

      @spec request!(atom, binary, body, headers, Keyword.t) :: Response.t
      def request!(method, url, body \\ "", headers \\ [], options \\ []) do
        {:ok, response} = request(method, url, body, headers, options)
        response
      end

      @spec get(binary, headers, Keyword.t) :: {:ok, Response.t}
      def get(url, headers \\ [], options \\ []),          do: request(:get, url, "", headers, options)

      @spec get!(binary, headers, Keyword.t) :: Response.t
      def get!(url, headers \\ [], options \\ []),         do: request!(:get, url, "", headers, options)

      @spec put(binary, body, headers, Keyword.t) :: {:ok, Response.t}
      def put(url, body, headers \\ [], options \\ []),    do: request(:put, url, body, headers, options)

      @spec put!(binary, body, headers, Keyword.t) :: Response.t
      def put!(url, body, headers \\ [], options \\ []),   do: request!(:put, url, body, headers, options)

      @spec head(binary, headers, Keyword.t) :: {:ok, Response.t}
      def head(url, headers \\ [], options \\ []),         do: request(:head, url, "", headers, options)

      @spec head!(binary, headers, Keyword.t) :: Response.t
      def head!(url, headers \\ [], options \\ []),        do: request!(:head, url, "", headers, options)

      @spec post(binary, body, headers, Keyword.t) :: {:ok, Response.t}
      def post(url, body, headers \\ [], options \\ []),   do: request(:post, url, body, headers, options)

      @spec post!(binary, body, headers, Keyword.t) :: Response.t
      def post!(url, body, headers \\ [], options \\ []),  do: request!(:post, url, body, headers, options)

      @spec patch(binary, body, headers, Keyword.t) :: {:ok, Response.t}
      def patch(url, body, headers \\ [], options \\ []),  do: request(:patch, url, body, headers, options)

      @spec patch!(binary, body, headers, Keyword.t) :: Response.t
      def patch!(url, body, headers \\ [], options \\ []), do: request!(:patch, url, body, headers, options)

      @spec delete(binary, headers, Keyword.t) :: {:ok, Response.t}
      def delete(url, headers \\ [], options \\ []),       do: request(:delete, url, "", headers, options)

      @spec delete!(binary, headers, Keyword.t) :: Response.t
      def delete!(url, headers \\ [], options \\ []),      do: request!(:delete, url, "", headers, options)

      @spec options(binary, headers, Keyword.t) :: {:ok, Response.t}
      def options(url, headers \\ [], options \\ []),      do: request(:options, url, "", headers, options)

      @spec options!(binary, headers, Keyword.t) :: Response.t
      def options!(url, headers \\ [], options \\ []),     do: request!(:options, url, "", headers, options)

      defoverridable Module.definitions_in(__MODULE__)
    end
  end

  def default_process_url(url) do
    case url |> String.slice(0, 8) |> String.downcase do
      "http://" <> _ -> url
      "https://" <> _ -> url
      _ -> "http://" <> url
    end
  end

  def request(method, request_url, process_status_code, process_headers, process_response_body) do
    case :ets.lookup(:uris_registry, {method, request_url}) do
      [{{^method, ^request_url}, {status_code, headers, body}}] ->
        response(process_status_code, process_headers, process_response_body, status_code, headers, body)
      [] -> { :ok, %Response{status_code: 404, body: "Not Found"} }
    end
  end

  defp response(process_status_code, process_headers, process_response_body, status_code, headers, body) do
    {:ok, %Response {
      status_code: process_status_code.(status_code),
      headers: process_headers.(headers),
      body: process_response_body.(body)
    } }
  end
end
