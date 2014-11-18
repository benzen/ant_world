var cellSize = 10;
var getContext = function(mapWidth, mapHeight){
  var canvas = $('<canvas>')
  .attr("width",mapWidth)
  .attr("height",mapHeight)
  .appendTo('body')
  [0];
  return canvas.getContext("2d");
};
var drawMap = function(ctx, mapWidth, mapHeight){
  //background
  ctx.fillStyle = "#339933";
  ctx.fillRect(0,0,mapWidth*cellSize, mapHeight*cellSize);

  //anthill
  ctx.fillStyle = "#895a29";
  ctx.fillRect(0,0,cellSize, cellSize);
};
var drawFood = function(ctx, foods){
  //food
  ctx.fillStyle = "#f14952";
  _.each(foods, function(food){
    var x = food[0];
    var y = food[1];
    ctx.fillRect(x, y, cellSize, cellSize);
  });

};
var drawAnt = function(ctx, position){
  ctx.fillStyle = "#000000";
  // console.log(data);
  ctx.fillRect(position[0],position[1],cellSize, cellSize);
};

var drawAnts = function(ctx){
  $.ajax('/ants', {success:function(data, status){
    _.each(data, function(antId){
        $.ajax('/status/ant/'+antId, { success:function(data, status){
          drawAnt(ctx, data)
        }});
      });
  }});
};


$(document).ready(function(){
  $.ajax('/status/map', {success:function(data, status){

    var mapWidth = data.dimension[0];
    var mapHeight = data.dimension[1];
    var ctx = getContext(mapWidth, mapHeight);

    drawMap(ctx, mapWidth, mapHeight);
    drawFood(ctx, data.food);

    setInterval(function(){drawAnts(ctx)}, 1);

  }});
});
