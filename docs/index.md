# Home

Personal notes and lessons learned.

<!-- markdownlint-disable MD033 -->
<canvas id="gol" width="400" height="200" style="border:1px solid #444; display:block; margin:1em 0;"></canvas>

<script>
const c = document.getElementById('gol'), ctx = c.getContext('2d');
const w = 80, h = 40, s = 5;
let grid = Array.from({length: w * h}, () => Math.random() > 0.7);
const idx = (x, y) => ((x + w) % w) + ((y + h) % h) * w;
const neighbors = (x, y) => [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]
  .reduce((n, [dx, dy]) => n + grid[idx(x+dx, y+dy)], 0);
setInterval(() => {
  grid = grid.map((cell, i) => {
    const n = neighbors(i % w, Math.floor(i / w));
    return n === 3 || (cell && n === 2);
  });
  ctx.fillStyle = '#1e1e1e';
  ctx.fillRect(0, 0, c.width, c.height);
  ctx.fillStyle = '#4caf50';
  grid.forEach((cell, i) => cell && ctx.fillRect((i % w) * s, Math.floor(i / w) * s, s - 1, s - 1));
}, 100);
</script>
<!-- markdownlint-enable MD033 -->

[Browse notes →](notes/site-setup.md)
