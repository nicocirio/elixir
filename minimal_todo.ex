defmodule MinimalTodo do
  def start do
    cargar_csv()
  end

  def get_command(data) do
    command = IO.gets(
    """
    Elije la opción deseada ingresando la primera letra del comando a ejecutar:
    L)eer tareas pendientes    A)gregar tareas        B)orrar una tarea
    C)argar un .csv            G)uardar un .csv       S)alir
    """)
      |> String.trim()
      |> String.downcase() #para homologar y que coincida dentro del "case"

    case command do
      "l" -> mostrar_tareas(data)
      "a" -> agregar_tarea(data)
      "b" -> borrar_tarea(data)
      "c" -> cargar_csv()
      "g" -> guardar_csv(data)
      "s" -> "Hasta luego"
       _   -> get_command(data)
    end

  end

  def guardar_csv(data) do
        # me fijo los titulos de la primera tarea (podría fijarme en cualquier tarea en realidad)
        titulos_atributos = data[hd(Map.keys(data))] |> Map.keys()
        encabezados = ["item"] ++ titulos_atributos
        # en tareas voy a obtener algo así [[tarea1, prioridad1, ...],[tarea2, prioridad2, ...]]
        tareas =
          Enum.into(data, [], fn una_tarea ->
            nombre_tarea = hd Map.keys(una_tarea) #al iterar con enum de a una a la vez, me devuelve una lista con un
            # unico valor que coincide con el nombre de la tarea.
            atributos_tarea = data[nombre_tarea] |> Map.values()
            resultado = [nombre_tarea] ++ [atributos_tarea]

          end)


        IO.puts(encabezados)
        IO.puts(tareas)


  end

  def agregar_tarea(data) do
    # obtener tarea y atributos
    nombre_tarea = obtener_nombre_tarea(data)
    atributos_tarea = obtener_atributos_tarea(data)
    map_nueva_tarea = %{nombre_tarea => atributos_tarea}
    nueva_data = Map.merge(data, map_nueva_tarea)
    IO.puts(~s{Nueva tarea "#{nombre_tarea}" agregada correctamente\n})
    get_command(nueva_data)
  end

  def obtener_nombre_tarea(data) do
    nombre_tarea = IO.gets("Ingrese el nombre de la nueva tarea:\n") |> String.trim
    case Map.has_key?(data, nombre_tarea) do
      true -> IO.puts("Ya existe la tarea #{nombre_tarea}. No pueden existir dos tareas iguales!")
              obtener_nombre_tarea(data)
      false -> nombre_tarea
    end
  end

  def obtener_atributos_tarea(data) do
    # me fijo los titulos de la primera tarea (podría fijarme en cualquier tarea en realidad)
    tarea1= hd(Map.keys(data))
    titulos_atributos = data[tarea1] |> Map.keys()

    #armo una lista con los valores de los atributos que me va a ir ingresando el usuario
    valores_atributos = Enum.into(titulos_atributos, [], fn titulo ->
      IO.gets("Ingrese el valor para el campo #{titulo}: \n") |> String.trim
    end)

    #con la los titulos y los valores ingresados por el usuario, armo el map de atributos
    map_atributos = Enum.zip(titulos_atributos, valores_atributos) |> Enum.into(%{})


  end


  def cargar_csv() do
    filename =
      IO.gets("Ingrese el nombre del archivo .csv: ")
      |> String.trim() #para no guardar el "enter" \n del usuario al ingresar el dato.
    read(filename)
      |> parse()
      |> get_command()
  end

  def borrar_tarea(data) do
    mostrar_tareas(data, false) #quiero que sólo muestre las tareas, no que me pida un comando...
    a_borrar = IO.gets("Escriba la tarea que desea borrar\n") |> String.trim()
    if Map.has_key?(data, a_borrar) do
      IO.puts(~s{La tarea "#{a_borrar}" fue borrada correctamente\n})
      #como los maps son inmutables, tengo que guardar el map con la tarea borrada
      # en un nuevo map.
      nueva_data = Map.drop(data, [a_borrar])
      # después de borrarlo, llamo de nuevo al menu...
      get_command(nueva_data)

    else
      IO.gets(~s{No existe la tarea "#{a_borrar}"!\n})
      borrar_tarea(data)
    end

  end

  def read(filename) do
    case File.read(filename) do
      {:ok, contenido_csv} -> contenido_csv #si lo puede abrir devuelve el contenido del archivo
      {:error, reason} -> IO.puts ~s(No se pudo abrir el archivo "#{filename}"\n)
                          IO.puts ~s("#{:file.format_error(reason)}"\n)
                          start() #si da error que, después de decir el error, pida ingresar un nuevo .csv
    end
  end

  #con las siguientes funciones "parse..." el objetivo es obtener un map dentro de otro map
  # de la siguiente manera, datos = %{"descripción del todo" => %{"atributos del todo}}.
  # por ejemplo %{"sacar la basura" -> %{"prioridad" => 1, "creado => 17.03.21, etc"}}
  def parse(contenido_csv) do
    #aprovecho el pattern matching para separar la primera linea con los títulos
    #de las demás lineas con los registros del todolist.
    [encabezados | registros] = String.split(contenido_csv, ~r{(\n|\r\n|\r)})
    #separo los títulos ya que vienen unidos por ; dentro del .csv
    titulos_atributos = tl String.split(encabezados, ";") #de los títulos me quedo con todos menos con el primero
    #que corresponde a "item", es decir, la descripción del todo.
    # por eso puse tl, para quedarme con el tail.
    parse_registros(registros, titulos_atributos)
  end

  def parse_registros(registros, titulos_atributos) do
    #acá para cada registro voy a construir el map %{"desc_todo" => %map_con_atributos}
    # que quedaría algo así %{"desc_todo" => %{atributo1 => desc1, atributo2=> desc2...}}
    Enum.reduce(registros, %{}, fn registro,reduccion_parcial ->
      [desc_todo | atributos_todo] = String.split(registro, ";")
      #como puede haber filas sin datos, me aseguro que estén completos viendo
      #que la cantidad de titulos de los atributos coincida con la cantidad de atributos...
      if Enum.count(titulos_atributos) == Enum.count(atributos_todo) do
        #asocio los títulos de los atributos con sus correspondientes atributos,
        #usando la función zip (ya que ambas listas coinciden en longitud)
        #y con un pipe meto eso en un map con enum.into
        map_con_atributos = Enum.zip(titulos_atributos, atributos_todo) |> Enum.into(%{})
        Map.merge(reduccion_parcial, %{desc_todo => map_con_atributos})
      else
        #cuando la cantidad de titulos no coincida con la cantidad de atributos
        # significa que ya llegué al final del listado de registros,
        #por  lo que en reducción parcial ya tendré el resultado final del map completo.
        reduccion_parcial
      end
    end)
  end
  def mostrar_tareas(data, next_command \\ true) do
    desc_todo = Map.keys(data)
    if Enum.count(desc_todo) > 0 do
      IO.puts("\nTenes las siguientes tareas pendientes:")
      Enum.each(desc_todo, fn x -> IO.puts(x) end)
      IO.puts("\n")
    else
      IO.puts("Estás al día, no tienes tareas pendientes!")
      IO.puts("\n")

    end



    if next_command do
      get_command(data)
    end
  end

end
