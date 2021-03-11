#lee todos los archivos de la ruta donde se ejecuta el script.
# crea una carpeta "imagenes" y mueve todos los
#archivos de fotos desde la carpeta donde se ejucta el scritp a la carpeta imagenes.

extensiones_fotos = ~r{\.(jpg|jpeg|gif|png|bmp)$}

archivos_de_imagenes =
  File.ls!() #listo los archivos de la ruta, en este caso como no puse ruta
  # toma la ruta desde donde ejecuto el script.
  |> Enum.filter(fn x -> Regex.match?(extensiones_fotos, x) end)

cantidad_imagenes = Enum.count(archivos_de_imagenes)

case cantidad_imagenes do
  0 -> IO.puts("No se encontraron imágenes en la carpeta")
  1 -> IO.puts("Se encontró una imagen en la carpeta")
  _ -> IO.puts(~s{Se encontraron #{cantidad_imagenes} imágenes en la carpeta})
end

case File.mkdir("./imagenes") do
  :ok       -> IO.puts "Ruta ./imagenes creada correctamente"
  {:error, _} -> IO.puts "No se pudo crear la ruta ./imagenes"
end

Enum.each(archivos_de_imagenes, fn archivo ->
  case File.rename(archivo, "./imagenes/#{archivo}") do
    :ok          -> IO.puts ~s{"#{archivo}" correctamente movido a la carpeta ./imagenes"}
    {:error, _}  -> IO.puts ~s{Error al intentar mover el archivo "#{archivo}" a la nueva carpeta}
  end
end)
