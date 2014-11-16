defmodule AntWorld do

  def start(_,_) do
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
    headers = HTTProt.Headers.new()
    |> HTTProt.Headers.put("content-type","application/json")
    req |> Request.reply(200, headers, resp )
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
    <html>
      <head>
      <script type="text/javascript" src="https://code.jquery.com/jquery-2.1.1.min.js" ></script>
      <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/lodash.js/2.4.1/lodash.compat.js" ></script>

      </head>
      <body>
        <script type="text/javascript">
          $(document).ready(function(){
            var height = 10;
            var width  = 10;

            var drawCell = function(content, x,y){
              var id = x+'-'+y
              var container = $('<div id='+id+'>')
                              .width(width)
                              .height(height)
                              .css("backgroundColor","green")
                              .offset({top:x*width, left:y*height})
                              .css("position", "absolute")
              return container;
            }
            $.ajax('/status/map', {success:function(data, status){
              var mapWidth = data.dimension[0];
              var mapHeight = data.dimension[1];
              var columns = _.range(data.dimension[0]);
              var rows = _.range(data.dimension[1]);

              _.each(rows, function(row){
                  return _.map(columns, function(column){
                    return drawCell( 'G', row, column);
                  });
                  $('body').append(buffer);
                  console.log("processed line", row);
              });

            }});
          });
        </script>
        <p>BOOYA<p>
      </body>
    </html>
    """
    req |> Request.reply(200, html )
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
    Enum.fetch( ants, (ant_index - 1))
    {:ok, ant} = Enum.fetch( ants, (ant_index - 1))
    send ant, {:status, cb}
  end

end
