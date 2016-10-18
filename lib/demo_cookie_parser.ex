defmodule DemoCookieParser do
  alias Plug.Conn.Cookies

  def run do
    hh = DemoCookieParser.headers "https://deliveroo.co.uk/"
    cc = DemoCookieParser.cookie_values hh
    cm = DemoCookieParser.analize_cookies cc
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
    {name, [ "value=#{value}" |attributes]}
  end
end
