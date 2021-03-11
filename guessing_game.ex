defmodule GuessingGame do
  def guess(a,b) when a>b do
    guess(b,a)
  end

  def guess(low, high) do
    respuesta = IO.gets("Mmm... estás pensando en el número #{mid(low, high)}?\n")
    case String.trim(respuesta) do
      "mayor" ->
        bigger(low, high)
      "menor" ->
        smaller(low, high)
      "si" ->
        IO.puts("sabia que podía adivinar!")
      _ ->
        IO.puts("ingrese 'mayor', 'menor' o 'si'")
        guess(low, high)
    end
  end
  def mid(low, high) do
    # divide la suma de ambos valores % 2.
    div(low + high, 2)
  end
  def bigger(low, high) do
    new_low = min(high, mid(low, high) + 1)
    guess(new_low, high)
  end

  def smaller(low, high) do
    new_high = max(low, mid(low, high) - 1)
    guess(low, new_high)
  end
end
