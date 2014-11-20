defmodule AntWorld do

  def start(_,_) do
    ctx = AntWorld.Bootstrap.world_of_ants(1_000,1_000,1)
    {:ok, pid} = Agent.start_link fn -> ctx end, name: :pids
    Cauldron.start Presenter, port: 4000
    {:ok, self}
  end

end

defmodule Presenter do

  use Cauldron

  # a map of property that define the world status
  def handle("GET", %URI{path: "/status/map"}, req) do
    {:ok, resp} = build_map_status_response()
    headers = HTTProt.Headers.new()
    |> HTTProt.Headers.put("content-type","application/json")
    req |> Request.reply(200, headers, resp )
  end

  # list of ants
  def handle("GET", %URI{path: "/ants"}, req) do
    {:ok,json} = build_ants_response()
    headers = HTTProt.Headers.new()
    |> HTTProt.Headers.put("content-type","application/json")
    req |> Request.reply(200, headers, json )
  end

  def handle("GET", %URI{path: "/status/ant/"<> id_as_string }, req) do
    cb = fn (err, ant_status)->

      if err do
        req |> Request.reply(500, "oups" )
      else
        {:ok, json } = JSON.encode(ant_status)
        headers = HTTProt.Headers.new()
        |> HTTProt.Headers.put("content-type","application/json")
        req |> Request.reply(200, headers, json )
      end
    end
    {id, _} = Integer.parse(id_as_string)
    build_ant_response id, cb
  end

  def handle("GET", %URI{path: "/"}, req) do
    headers = HTTProt.Headers.new()
    |> HTTProt.Headers.put("content-type","text/html")

    File.open "html/index.html", fn(file) ->
      req |> Request.reply(200, headers, IO.read(file, :all) )
    end
  end

  def handle("GET", %URI{path: "/js/"<>jsfile}, req) do
    headers = HTTProt.Headers.new()
    |> HTTProt.Headers.put("content-type","application/javascript")
    File.open "js/"<>jsfile,[:read], fn(file) ->
      req |> Request.reply(200, headers, IO.read(file, :all))
    end
  end
  def handle("GET", %URI{path: _}, req) do
    req |> Request.reply(404, "ayn't got that" )
  end

  def build_map_status_response() do
    {world,_ants} = Agent.get :pids, &(&1)
    world_state = GenServer.call world, :state
    JSON.encode(world_state)
  end

  def build_ants_response() do
    {_world,ants} = Agent.get :pids, &(&1)
    nb_ants = Enum.count ants
    l = Enum.to_list 1..nb_ants
    JSON.encode(l)
  end

  def build_ant_response(ant_index, cb) do
    {_world,ants} = Agent.get :pids, &(&1)
    {:ok, ant} = Enum.fetch( ants, (ant_index - 1))
    send ant, {:status, cb}
  end

end
