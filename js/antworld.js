var cellSize = 10;
var getContext = function(mapWidth, mapHeight){
  if( $('canvas').length){
    return $('canvas')[0].getContext("2d");
  }
  var canvas = $('<canvas>')
  .attr("width",mapWidth)
  .attr("height",mapHeight)
  .appendTo('body')
  [0];
  return canvas.getContext("2d");
};
var drawPoint = function(ctx, position, color){
  ctx.fillStyle = color;
  ctx.fillRect(position[0],position[1],cellSize, cellSize);
};

var drawListOfPoint = function(ctx, listOfPoint, color){
  _.each(listOfPoint, function(position){
    drawPoint(ctx, position, color);
  });
};

var drawMap = function(ctx, mapWidth, mapHeight){
  //background
  ctx.fillStyle = "#339933";
  ctx.fillRect(0,0,mapWidth*cellSize, mapHeight*cellSize);
};


var drawAnts = function(ctx){
  $.ajax('/ants', {success:function(data, status){
    _.each(data, function(antId){
        $.ajax('/status/ant/'+antId, { success:function(data, status){
          drawPoint(ctx, data, "#000000")
        }});
      });
  }});
};

var drawWorld = function(){
  $.ajax('/status/map', {success:function(data, status){

    var mapWidth = data.dimension[0];
    var mapHeight = data.dimension[1];
    var ctx = getContext(mapWidth, mapHeight);

    drawMap(ctx, mapWidth, mapHeight);
    drawPoint(ctx, [0,0], "#895a29");
    drawListOfPoint(ctx, data.path_position, "#666666");
    drawListOfPoint(ctx, data.food_position, "#f14952");
    drawAnts(ctx)
  }});

};

$(document).ready(function(){
    // var test = function(){return true};
    // var errCb = function(err){
    //   console.log(err);
    // };
    // async.until(test, drawWorld, errCb);
    setInterval(drawWorld, 100);
});
