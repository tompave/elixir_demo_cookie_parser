defmodule DemoCookieParser do
  alias Plug.Conn.Cookies

  @url "https://deliveroo.co.uk/"

  def run do
    @url
    |> headers
    |> cookie_values
    |> analize_cookies
  end

  def headers(url \\ "https://www.google.co.uk/") do
    %{ headers: headers } = HTTPoison.get!(url)
    headers
  end

  def plug_decoded_cookies do
    Enum.map cookie_values, fn(cookie_str) ->
      Cookies.decode(cookie_str)
    end
  end

  def cookie_values(the_headers \\ headers) do
    the_headers
    |> Enum.filter(&(elem(&1, 0) == "Set-Cookie"))
    |> Enum.map(&Kernel.elem(&1, 1))
  end


  def analize_cookies(list_of_raw_cookies) do
    Enum.into(list_of_raw_cookies, %{}, fn(cookie) -> analize_cookie(cookie) end)
  end

  def analize_cookie(cookie_str) do
    [cookie_value | attributes] =
      cookie_str
      |> String.split(";")
      |> Enum.map(&String.strip/1)

    [name, value] = String.split(cookie_value, "=")
    attrs = ["value=#{value}" | attributes]
    {name, attr_list_to_map(attrs)}
  end

  defp attr_list_to_map(list) when is_list(list) do
    list
    |> Enum.map(&parse_attribute/1)
    |> Enum.into(%{})
  end


  defp parse_attribute(str) do
    parts = String.split(str, "=")
    case length(parts) do
      2 -> List.to_tuple(parts)
      1 -> {hd(parts), true}
      _ -> nil
    end
  end
end
