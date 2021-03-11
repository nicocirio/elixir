filename =
  IO.gets("File to count the words from (h for help): \n")
  |> String.trim()

if filename == "h" do
  IO.puts("""
  Usage: [filename] -[flags]
  Flags
  -l  displays line count
  -c  displays character count
  -w  displays word count (default if flag not provided)
  Multiple flags may be used. For example,

  somefile.txt -lc   will display line and character count.
  """)
else
  parts = String.split(filename, "-")
  filename = List.first(parts) |> String.trim()  #me quedo con el primer elemento de la lista
  #y como hay un espacio entre el nombre del archivo y el -, le aplico un trim.
  #Enum.at(parts, 1) de la lista "parts" me quedo con el elemento en la posición 1.
  flags =
    case Enum.at(parts, 1) do
      nil ->
        ["w"] #si no ponen nada el flag es w por defecto
      chars ->
        String.split(chars, "") #separo lo que ingresaron en una lista
        |> Enum.filter(fn x -> x != "" end) #como la lista que se genrea dsp del split
        #tiene como último elemento un "", filtro para que lo excluya.
    end

  #leo el archivo
  body = File.read!(filename)
  lines = String.split(body, ~r{(\r|\r\n|\n)}) #segun el sistema operativo, la nueva linea se puede
  # expresar como "\r", "\r\n" o como "\n"
  words =
    String.split(body, ~r{(\\n|[^\w'])+})
    |> Enum.filter(fn x -> x != "" end)
  chars = String.split(body, "") |> Enum.filter(fn x -> x != "" end)

  # enum each me permite ejecutar una función para cada uno de los elementos del enumerable,
  # en este caso el enumerable es la lista con los flags ingresados por el usuario
  Enum.each(flags, fn flag ->
    case flag do
      "l" -> IO.puts("Lines: #{Enum.count(lines)}")
      "c" -> IO.puts("Chars: #{Enum.count(chars)}")
      "w" -> IO.puts("Words: #{Enum.count(words)}")
      _ -> nil
    end
  end)
end
