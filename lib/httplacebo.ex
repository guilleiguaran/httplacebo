defmodule HTTPlacebo.Response do
  defstruct status_code: nil, body: nil, headers: []
  @type t :: %__MODULE__{status_code: integer, body: binary, headers: list}
end

defmodule HTTPlacebo do
  use HTTPlacebo.Base
end
