defmodule Weather.CLI do
  def main(argv) do
    argv
    |> parse_args
    |> fetch_weather
    |> handle_response
    |> parse_json
    |> print_output
  end

  def parse_args([query]) do
    query
  end

  def parse_args(_) do
    IO.puts """
      Usage: weather "Ottawa, ON, Canada"
      """
  end

  def fetch_weather(query) do
    encoded_query = URI.encode(query)
    IO.puts("Fetching weather #{encoded_query}")
    HTTPoison.get("http://api.openweathermap.org/data/2.5/weather?q=#{encoded_query}&units=metric")
  end

  def handle_response({:ok, %{body: body, status_code: 200}}) do
    IO.puts """
      Good response
      Code: 200
      Body: #{body}
      """
    body
  end

  def handle_response({_, %{body: body, status_code: code}}) do
    IO.puts """
      Bad response
      Code: #{code}
      Body: #{body}
      """
    System.halt(2)
  end

  def parse_json(body) do
    Poison.Parser.parse!(body)
  end

  def print_output(%{"weather" => [%{"description" => description}], "name" => city_name, "main" => %{"temp" => temp}}) do
    IO.puts "#{city_name}, #{description}. #{temp}°C."
  end

  def print_output(_) do
    IO.puts """
      Response missing expected data
      """
    System.halt(2)
  end
end
