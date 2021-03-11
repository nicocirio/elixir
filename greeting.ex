defmodule Greeting do
  @autor "Nico"
  def greet do
    nombre = IO.gets("What´s your name?\n") |> String.trim()
    case nombre do
      @autor -> "Wow, #{@autor} is the name of the one who programmed me!"
      _ -> "Hello #{nombre}!"
    end
  end
end
