nombre_archivo = IO.gets("file to count the words from: ") |> String.trim()

palabras =
  File.read!(nombre_archivo) #el ! es para que tire error si no lo puede leer.
  |> String.split(~r{(\\n|[^\w'])+}) #lo divido por lo definido en la regular expression y obtengo una lista
  |> Enum.filter(fn x -> x != "" end) # que la filtro por todo lo que no sea vacío

# cuento los elementos de esa lista e imprimo luego el número total de palabras
# del archivo.
IO.puts("la cantidad total de palabras del archivo es: ")
palabras |> Enum.count() |> IO.puts()
IO.puts("la lista de palabras es: ")
palabras |> IO.inspect()
