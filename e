<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>FORMLESS</title>
<style>
body {
  margin: 0;
  overflow: hidden;
  background: radial-gradient(circle at center, #0a0a12, #000);
  font-family: sans-serif;
  color: white;
}
canvas {
  display: block;
}
#ui {
  position: absolute;
  top: 20px;
  left: 20px;
  opacity: 0.7;
  font-size: 14px;
  letter-spacing: 2px;
}
</style>
</head>
<body>
<canvas id="game"></canvas>
<div id="ui">STABILITY</div>

<script>
const canvas = document.getElementById("game");
const ctx = canvas.getContext("2d");
const ui = document.getElementById("ui");

canvas.width = window.innerWidth;
canvas.height = window.innerHeight;

const RADIUS = 8;
const HEX = 35;

let grid = {};
let gameOver = false;

let echo = { q: 0, r: 0 };

function key(q,r){ return q+","+r; }

function inside(q,r){
  return Math.abs(q)<=RADIUS &&
         Math.abs(r)<=RADIUS &&
         Math.abs(q+r)<=RADIUS;
}

function isEdge(q,r){
  return Math.abs(q)==RADIUS ||
         Math.abs(r)==RADIUS ||
         Math.abs(q+r)==RADIUS;
}

function neighbors(q,r){
  return [
    [q+1,r],[q-1,r],
    [q,r+1],[q,r-1],
    [q+1,r-1],[q-1,r+1]
  ];
}

function hexToPixel(q,r){
  const x = canvas.width/2 + HEX * (Math.sqrt(3)*q + Math.sqrt(3)/2*r);
  const y = canvas.height/2 + HEX * (3/2*r);
  return {x,y};
}

function pixelToHex(x,y){
  x -= canvas.width/2;
  y -= canvas.height/2;
  const q = (Math.sqrt(3)/3 * x - 1/3 * y) / HEX;
  const r = (2/3 * y) / HEX;
  return hexRound(q,r);
}

function hexRound(q,r){
  let x=q, z=r, y=-x-z;
  let rx=Math.round(x), ry=Math.round(y), rz=Math.round(z);
  let x_diff=Math.abs(rx-x);
  let y_diff=Math.abs(ry-y);
  let z_diff=Math.abs(rz-z);

  if(x_diff>y_diff && x_diff>z_diff) rx=-ry-rz;
  else if(y_diff>z_diff) ry=-rx-rz;
  else rz=-rx-ry;

  return {q:rx, r:rz};
}

function drawHex(q,r,color,glow=false){
  const {x,y}=hexToPixel(q,r);
  ctx.beginPath();
  for(let i=0;i<6;i++){
    const angle=Math.PI/3*i;
    const px=x+HEX*Math.cos(angle);
    const py=y+HEX*Math.sin(angle);
    i===0?ctx.moveTo(px,py):ctx.lineTo(px,py);
  }
  ctx.closePath();
  ctx.fillStyle=color;
  ctx.shadowBlur=glow?20:0;
  ctx.shadowColor=color;
  ctx.fill();
  ctx.shadowBlur=0;
}

function bfs(){
  let queue=[[echo.q,echo.r]];
  let visited={};
  let parent={};
  visited[key(echo.q,echo.r)]=true;

  while(queue.length){
    const [q,r]=queue.shift();

    if(isEdge(q,r)){
      let path=[[q,r]];
      while(parent[key(q,r)]){
        [q,r]=parent[key(q,r)];
        path.unshift([q,r]);
      }
      return path;
    }

    for(let [nq,nr] of neighbors(q,r)){
      if(!inside(nq,nr)) continue;
      if(grid[key(nq,nr)]) continue;
      if(!visited[key(nq,nr)]){
        visited[key(nq,nr)]=true;
        parent[key(nq,nr)]=[q,r];
        queue.push([nq,nr]);
      }
    }
  }
  return null;
}

function moveEcho(){
  const path=bfs();
  if(!path){
    ui.innerText="CONTAINED";
    gameOver=true;
    return;
  }
  if(path.length<=1){
    ui.innerText="DISSOLVED";
    gameOver=true;
    return;
  }
  echo.q=path[1][0];
  echo.r=path[1][1];

  if(isEdge(echo.q,echo.r)){
    ui.innerText="DISSOLVED";
    gameOver=true;
  }
}

function draw(){
  ctx.clearRect(0,0,canvas.width,canvas.height);

  for(let q=-RADIUS;q<=RADIUS;q++){
    for(let r=-RADIUS;r<=RADIUS;r++){
      if(!inside(q,r)) continue;
      if(grid[key(q,r)]){
        drawHex(q,r,"#6622ff");
      }
    }
  }

  drawHex(echo.q,echo.r,"#00ffff",true);
}

canvas.addEventListener("click",e=>{
  if(gameOver) return;

  const hex=pixelToHex(e.clientX,e.clientY);
  if(!inside(hex.q,hex.r)) return;
  if(hex.q===echo.q && hex.r===echo.r) return;

  grid[key(hex.q,hex.r)]=true;
  moveEcho();
  draw();
});

draw();
</script>
</body>
</html>
