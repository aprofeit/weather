defmodule Weather.CLI do
  def main(argv) do
    argv
    |> parse_args
    |> fetch_weather
    |> handle_response
    |> parse_json
    |> print_output
  end

  def parse_args([query]), do: query

  def parse_args(_) do
    IO.puts """
      Usage: weather "Ottawa, ON, Canada"
      """
  end

  def fetch_weather(query) do
    HTTPoison.get("http://api.openweathermap.org/data/2.5/weather?q=#{URI.encode(query)}&units=metric")
  end

  def handle_response({:ok, %{body: body, status_code: 200}}), do: body

  def handle_response({_, %{body: body, status_code: code}}) do
    IO.puts """
      Bad response
      Code: #{code}
      Body: #{body}
      """
    System.halt(2)
  end

  def parse_json(body), do: Poison.Parser.parse!(body)

  def print_output(%{"weather" => [%{"description" => description}], "name" => city_name, "main" => %{"temp" => temp}}) do
    IO.puts "#{city_name}. #{String.capitalize(description)}. #{temp}°C."
  end

  def print_output(_) do
    IO.puts """
      Response missing expected data
      """
    System.halt(2)
  end
end
