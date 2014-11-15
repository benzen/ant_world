defmodule AntWorld do

  def start(_,_) do
    # port = 4000
    # IO.puts "creating the world"
    # AntWorld.Bootstrap.world_of_ants(1000, 1000, 15)
    # Cauldron.start AntWorld, port: port

    ctx = AntWorld.Bootstrap.world_of_ants(1_000,1_000,15)
    {:ok, pid} = Agent.start_link fn -> ctx end, name: :pids
    IO.puts "created Agent #{inspect pid}"

    Cauldron.start Presenter, port: 4000
    {:ok, self}
  end

end

defmodule Presenter do

  use Cauldron

  # a map of property that define the world status
  def handle("GET", %URI{path: "/status/map"}, req) do
    {:ok, resp} = build_map_status_response()
    req |> Request.reply(200, resp )
  end

  # list of ants
  def handle("GET", %URI{path: "/ants"}, req) do
    {:ok,json} = build_ants_response()
    req |> Request.reply(200, json )
  end

  def handle("GET", %URI{path: "/status/ant/"<> id_as_string }, req) do
    cb = fn (err, ant_status)->

      if err do
        req |> Request.reply(500, "oups" )
      else
        {:ok, json } = JSON.encode(ant_status)
        req |> Request.reply(200, json )
      end
    end
    {id, _} = Integer.parse(id_as_string)
    build_ant_response id, cb
  end

  def handle("GET", %URI{path: "/"}, req) do
    html = """
    <body>
      <p>BOOYA<p>
    </body>
    """
    req |> Request.reply(200, html )
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
    Enum.fetch( ants, (ant_index - 1))
    {:ok, ant} = Enum.fetch( ants, (ant_index - 1))
    send ant, {:status, cb}
  end

end
