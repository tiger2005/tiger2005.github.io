#let svg-num = (v) => {
  if v < 0 {
    "-" + str(0 - v)
  } else {
    str(v)
  }
}

#let line = (id, x1, y1, x2, y2, idx) => {
  let dx = x2 - x1
  let dy = y2 - y1
  let seglen = calc.sqrt(dx * dx + dy * dy)

  html.elem("g", {
    html.elem("defs", {
      html.elem(
        "linearGradient",
        attrs: (
          id: id,
          gradientUnits: "userSpaceOnUse",
          x1: svg-num(x1),
          y1: svg-num(y1),
          x2: svg-num(x2),
          y2: svg-num(y2),
        ),
        {
          html.elem("stop", attrs: (offset: "0%", "stop-color": "gray", "stop-opacity": "0"))
          html.elem("stop", attrs: (offset: "25%", "stop-color": "gray", "stop-opacity": "1"))
          html.elem("stop", attrs: (offset: "75%", "stop-color": "gray", "stop-opacity": "1"))
          html.elem("stop", attrs: (offset: "100%", "stop-color": "gray", "stop-opacity": "0"))
        },
      )
    })
    html.elem(
      "line",
      attrs: (
        class: "hero-grid-line",
        style: "--line-delay: " + svg-num(idx) + "; --line-len: " + svg-num(seglen) + ";",
        stroke: "url(#" + id + ")",
        "stroke-width": "1",
        "stroke-linecap": "round",
        "stroke-dasharray": svg-num(seglen),
        "stroke-dashoffset": svg-num(seglen),
        x1: svg-num(x1),
        y1: svg-num(y1),
        x2: svg-num(x2),
        y2: svg-num(y2),
      ),
    )
  })
}

#let rotate = (x, y, angle, cx, cy) => {
  let rad = angle * calc.pi / 180
  let dx = x - cx
  let dy = y - cy
  let nx = cx + dx * calc.cos(rad) - dy * calc.sin(rad)
  let ny = cy + dx * calc.sin(rad) + dy * calc.cos(rad)
  (nx, ny)
}

#let cx = 150
#let cy = 150
#let len = 210
#let count = 9
#let step = 0.05
#let spacing = len / (count - 1)

#let lines = {
  let result = ()
  let idx = 0
  for i in range(0, count) {
    let x = cx - len/2 + i * spacing
    let rlen = len/2 + calc.min(i, count - 1 - i) * calc.sqrt(3) / 3 * spacing
    result.push(line("lg-v-" + str(i), x, cy - rlen, x, cy + rlen, idx))
    idx += 1
  }
  for angle in (120, 240) {
    for i in range(0, count) {
      let rlen = len/2 + calc.min(i, count - 1 - i) * calc.sqrt(3) / 3 * spacing
      let x1 = cx - len/2 + i * spacing
      let y1 = cy - rlen
      let x2 = cx - len/2 + i * spacing
      let y2 = cy + rlen
      let (rx1, ry1) = rotate(x1, y1, angle, cx, cy)
      let (rx2, ry2) = rotate(x2, y2, angle, cx, cy)
      result.push(line("lg-r" + str(angle) + "-" + str(i), rx1, ry1, rx2, ry2, idx))
      idx += 1
    }
  }
  result
}

#let triangles = {
  let left-tri = (x, y) => {
    (
      (cx + x, cy + y),
      (cx + x + spacing, cy + y - spacing / calc.sqrt(3)),
      (cx + x + spacing, cy + y + spacing / calc.sqrt(3)),
    )
  }

  let right-tri = (x, y) => {
    (
      (cx + x, cy + y),
      (cx + x - spacing, cy + y - spacing / calc.sqrt(3)),
      (cx + x - spacing, cy + y + spacing / calc.sqrt(3)),
    )
  }

  let rotate-tri = (tri, angle) => {
    let out = ()
    for p in tri {
      let (rx, ry) = rotate(p.at(0), p.at(1), angle, cx, cy)
      out.push((rx, ry))
    }
    out
  }

  let unit = spacing / calc.sqrt(3)

  let red = (
    left-tri(- spacing, -5 * unit),
    right-tri(spacing, -5 * unit),
    left-tri(spacing, -5 * unit),
    left-tri(0, -6 * unit),
    right-tri(2 * spacing, -6 * unit),

    right-tri(- spacing, 3 * unit),
    left-tri(-2 * spacing, 4 * unit),
    right-tri(- spacing, 5 * unit),
    left-tri(-2 * spacing, 6 * unit),
    right-tri(0, 6 * unit),
    left-tri(- spacing, 5 * unit),
    right-tri(0, 4 * unit),
    left-tri(- spacing, 3 * unit),
    right-tri(spacing, 5 * unit),
    left-tri(0, 4 * unit),
    right-tri(spacing, 3 * unit),
    left-tri(0, 2 * unit),
    right-tri(spacing, unit),
    left-tri(0, 0),
    right-tri(2 * spacing, 4 * unit),
    left-tri(spacing, 3 * unit),
    right-tri(2 * spacing, 2 * unit),
    left-tri(spacing, unit),
    right-tri(2 * spacing, 0),
  )

  let green = ()
  let blue = ()
  for tri in red {
    blue.push(rotate-tri(tri, 120))
    green.push(rotate-tri(tri, 240))
  }

  (
    red: red,
    green: green,
    blue: blue,
  )
}

#let tri-points = (tri) => {
  let p0 = tri.at(0)
  let p1 = tri.at(1)
  let p2 = tri.at(2)
  svg-num(p0.at(0)) + "," + svg-num(p0.at(1)) + " " + svg-num(p1.at(0)) + "," + svg-num(p1.at(1)) + " " + svg-num(p2.at(0)) + "," + svg-num(p2.at(1))
}

#let draw-borders = () => {
  let unit = spacing / calc.sqrt(3)

  let red-border = (
    (
      (-spacing, -5 * unit),
      (spacing, -7 * unit),
      (2 * spacing, -6 * unit),
      (2 * spacing, -4 * unit),
    ),
    (
      (spacing, -7 * unit),
      (spacing, -5 * unit),
    ),
    (
      (-2 * spacing, 2 * unit),
      (-2 * spacing, 6 * unit),
      (-spacing, 7 * unit),
      (2 * spacing, 4 * unit),
      (2 * spacing, 0),
      (spacing, -unit),
      (0, 0),
      (0, 2 * unit),
      (-spacing, 3 * unit),
      (-2 * spacing, 2 * unit),
    ),
    (
      (-2 * spacing, 6 * unit),
      (spacing, 3 * unit),
      (spacing, -unit),
    ),
    (
      (spacing, 3 * unit),
      (2 * spacing, 4 * unit)
    )
  )

  let to-abs-path = (path) => {
    let out = ()
    for p in path {
      out.push((cx + p.at(0), cy + p.at(1)))
    }
    out
  }

  let rotate-path = (path, angle) => {
    let out = ()
    for p in path {
      let (rx, ry) = rotate(p.at(0), p.at(1), angle, cx, cy)
      out.push((rx, ry))
    }
    out
  }

  let path-points = (path) => {
    let parts = ()
    for p in path {
      parts.push(svg-num(p.at(0)) + "," + svg-num(p.at(1)))
    }
    parts.join(" ")
  }

  let red-abs = ()
  for path in red-border {
    red-abs.push(to-abs-path(path))
  }

  let green-border = ()
  let blue-border = ()
  for path in red-abs {
    green-border.push(rotate-path(path, 120))
    blue-border.push(rotate-path(path, 240))
  }

  for group in (red-abs, green-border, blue-border) {
    for path in group {
      html.elem(
        "polyline",
        attrs: (
          points: path-points(path),
          fill: "none",
          stroke: "rgb(64, 64, 64)",
          "stroke-width": "2",
          "stroke-linecap": "round",
          "stroke-linejoin": "round",
        ),
      )
    }
  }
}

#let draw-triangles = (items, color) => {
  for tri in items {
    html.elem(
      "polygon",
      attrs: (
        points: tri-points(tri),
        fill: color,
        "fill-opacity": "0.2",
        stroke: color,
        "stroke-width": "0.9",
      ),
    )
  }
}

#let draw-triangles-final = (items, color) => {
  for tri in items {
    html.elem(
      "polygon",
      attrs: (
        points: tri-points(tri),
        fill: color,
        "fill-opacity": "1",
        stroke: color,
        "stroke-width": "1",
      ),
    )
  }
}

#let gen-header-svg = () => {
  html.elem("svg", attrs: (
    class: "hero-grid-svg",
    style: "--line-step: " + svg-num(step) + "s; --line-draw: 0.3s; --phase-tri-start: 2s; --phase-final-start: 3s; --phase-fade: 0.5s;",
    xmlns: "http://www.w3.org/2000/svg",
    viewBox: "0 0 300 300",
    fill: "none",
    width: "100%",
    height: "100%",
  ), {
    html.elem("g", attrs: (class: "line-layer"), {
      for l in lines {
        l
      }
    })
    html.elem("g", attrs: (class: "tri-preview-layer"), {
      draw-triangles(triangles.at("red"), "#D73A34")
      draw-triangles(triangles.at("green"), "#58AC59")
      draw-triangles(triangles.at("blue"), "#444FC3")
    })
    html.elem("g", attrs: (class: "final-layer"), {
      draw-triangles-final(triangles.at("red"), "#D73A34")
      draw-triangles-final(triangles.at("green"), "#58AC59")
      draw-triangles-final(triangles.at("blue"), "#444FC3")
      draw-borders()
    })
  })
}