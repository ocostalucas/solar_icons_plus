// Converts Solar SVG paths from fill-rule="evenodd" to fill-rule="nonzero".
//
// Fantasticon/base-font-tools rasterize fonts using the nonzero winding rule,
// which reads a hole only when its subpath runs in the OPPOSITE direction to
// the contour that encloses it. The Solar source uses evenodd, where a hole is
// any subpath contained inside an odd number of other subpaths, regardless of
// direction. As a result icons with cut-outs (add-circle, accessibility, ...)
// had their holes painted solid. This module keeps the same visual result by
// reversing the winding of every odd-depth subpath, then drops the evenodd rule
// so downstream converters use nonzero consistently.
//
// Usage:
//   const { convertFile } = require("./evenodd_to_nonzero.js");
//   convertFile(svgPath);

const fs = require("fs");
const svgpath = require("svgpath").default || require("svgpath");

const TAU = Math.PI * 2;

function parseSegments(d) {
  const normalized = [];
  svgpath(d)
    .unarc()
    .abs()
    .unshort()
    .iterate((seg) => normalized.push(seg.slice()));
  // Expand absolute H/V into L so every geometry segment carries its full point.
  const segs = [];
  let cur = [0, 0];
  for (const seg of normalized) {
    const c = seg[0];
    if (c === "M") {
      cur = [seg[1], seg[2]];
      segs.push(seg);
    } else if (c === "H") {
      segs.push(["L", seg[1], cur[1]]);
      cur[0] = seg[1];
    } else if (c === "V") {
      segs.push(["L", cur[0], seg[1]]);
      cur[1] = seg[1];
    } else if (c === "Z") {
      segs.push(seg);
    } else if (c === "L") {
      cur = [seg[1], seg[2]];
      segs.push(seg);
    } else if (c === "Q") {
      cur = [seg[3], seg[4]];
      segs.push(seg);
    } else if (c === "C") {
      cur = [seg[5], seg[6]];
      segs.push(seg);
    }
  }
  return segs;
}

// Splits normalized segments (M/L/C/Q/Z only) into subpaths.
function splitSubpaths(segs) {
  const subs = [];
  let cur = null;
  for (const seg of segs) {
    if (seg[0] === "M") {
      cur = { m: [seg[1], seg[2]], segs: [] };
      subs.push(cur);
    } else if (seg[0] === "Z") {
      // subpath closed; nothing to record
    } else {
      if (cur) cur.segs.push(seg);
    }
  }
  return subs;
}

const lerp = (a, b, t) => a + (b - a) * t;
const vec = (a, b, t) => [lerp(a[0], b[0], t), lerp(a[1], b[1], t)];
const quad = (a, b, c, t) => vec(vec(a, b, t), vec(b, c, t), t);
const cubic = (a, b, c, d, t) =>
  vec(vec(vec(a, b, t), vec(b, c, t), t), vec(vec(b, c, t), vec(c, d, t), t), t);

// Flattens a subpath into a polygon of sample points for ray-cast containment.
function flattenSubpath(sp) {
  const poly = [sp.m];
  let p = sp.m;
  for (const seg of sp.segs) {
    const c = seg[0];
    if (c === "L") {
      poly.push([seg[1], seg[2]]);
      p = [seg[1], seg[2]];
    } else if (c === "Q") {
      const q = [seg[3], seg[4]];
      for (let k = 1; k < 10; k++) poly.push(quad(p, [seg[1], seg[2]], q, k / 10));
      p = q;
    } else if (c === "C") {
      const q = [seg[5], seg[6]];
      for (let k = 1; k < 16; k++)
        poly.push(cubic(p, [seg[1], seg[2]], [seg[3], seg[4]], q, k / 16));
      p = q;
    }
  }
  return poly;
}

function pointInPoly(pos, poly) {
  let inside = false;
  for (let i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    const xi = poly[i][0],
      yi = poly[i][1];
    const xj = poly[j][0],
      yj = poly[j][1];
    const intersect =
      yi > pos[1] !== yj > pos[1] &&
      pos[0] < ((xj - xi) * (pos[1] - yi)) / (yj - yi) + xi;
    if (intersect) inside = !inside;
  }
  return inside;
}

function computeDepth(subpath, others) {
  // Number of OTHER subpaths containing this subpath's reference point.
  let depth = 0;
  for (const other of others) {
    if (pointInPoly(subpath.m, flattenSubpath(other))) depth++;
  }
  return depth;
}

// Reverses winding of a closed subpath (preserves L/Q/C, shape-exact).
function reverseSubpath(sp) {
  const pts = [sp.m];
  for (const seg of sp.segs) {
    const c = seg[0];
    if (c === "L") pts.push([seg[1], seg[2]]);
    else if (c === "Q") pts.push([seg[3], seg[4]]);
    else if (c === "C") pts.push([seg[5], seg[6]]);
  }
  const out = [];
  const last = pts[pts.length - 1];
  out.push(["M", last[0], last[1]]);
  for (let i = sp.segs.length - 1; i >= 0; i--) {
    const seg = sp.segs[i];
    const end = pts[i];
    const c = seg[0];
    if (c === "L") out.push(["L", end[0], end[1]]);
    else if (c === "Q") out.push(["Q", seg[1], seg[2], end[0], end[1]]);
    else if (c === "C")
      out.push(["C", seg[3], seg[4], seg[1], seg[2], end[0], end[1]]);
  }
  out.push(["Z"]);
  return out;
}

const fmt = (n) => {
  const r = Math.round(n * 1000) / 1000;
  return Object.is(r, -0) ? "0" : String(r);
};

function emit(subpaths) {
  return subpaths
    .map((sp) =>
      sp
        .map((seg) => seg[0] + " " + seg.slice(1).map(fmt).join(" "))
        .join(" "),
    )
    .join(" ");
}

function keepSubpath(sp) {
  return [["M", sp.m[0], sp.m[1]], ...sp.segs.map((s) => s.slice()), ["Z"]];
}

// d (evenodd) -> d (nonzero) string.
//
// Font tools rasterize with the nonzero rule, where a hole is a subpath whose
// winding is OPPOSITE the contour enclosing it. To reproduce evenodd exactly we
// force every fill subpath (even depth) to share one winding and every hole
// subpath (odd depth) to use the opposite winding, regardless of the direction
// in which the source happened to draw them.
function evenOddToNonZero(d) {
  const subs = splitSubpaths(parseSegments(d));
  if (subs.length < 2) return d;
  let fillDir = null;
  for (const sp of subs) {
    const others = subs.filter((o) => o !== sp);
    const depth = computeDepth(sp, others);
    if (depth % 2 === 0) {
      // Outermost / fill contour; all fills share its winding.
      const w = signedArea(flattenSubpath(sp));
      if (fillDir === null) fillDir = w >= 0 ? 1 : -1;
    }
  }
  if (fillDir === null) fillDir = 1;
  const output = [];
  for (const sp of subs) {
    const others = subs.filter((o) => o !== sp);
    const depth = computeDepth(sp, others);
    const wantHole = depth % 2 === 1;
    const wantDir = wantHole ? -fillDir : fillDir;
    const w = signedArea(flattenSubpath(sp));
    const dir = w >= 0 ? 1 : -1;
    output.push(dir === wantDir ? keepSubpath(sp) : reverseSubpath(sp));
  }
  return emit(output);
}

function signedArea(poly) {
  let a = 0;
  for (let i = 0; i < poly.length; i++) {
    const x1 = poly[i][0],
      y1 = poly[i][1];
    const x2 = poly[(i + 1) % poly.length][0],
      y2 = poly[(i + 1) % poly.length][1];
    a += x1 * y2 - x2 * y1;
  }
  return a;
}

// Rewrites the <path> inside a standalone SVG for nonzero winding. Returns the
// updated SVG text.
function convertSvg(svg) {
  return svg.replace(
    /<path([^>]*?)\/?>/gi,
    (match, attrs) => {
      const fillEven = /\bfill-rule\s*=\s*"evenodd"/i.test(attrs);
      const clipEven = /\bclip-rule\s*=\s*"evenodd"/i.test(attrs);
      if (!fillEven && !clipEven) return match;
      const dm = attrs.match(/\bd\s*=\s*"([^"]*)"/i);
      const nd = dm ? evenOddToNonZero(dm[1]) : dm ? dm[1] : "";
      let next = attrs;
      next = next.replace(/\sd\s*=\s*"[^"]*"/i, "");
      next = next.replace(/\sfill-rule\s*=\s*"[^"]*"/gi, "");
      next = next.replace(/\sclip-rule\s*=\s*"[^"]*"/gi, "");
      next += ` d="${nd}" fill-rule="nonzero"`;
      return "<path" + next + " />";
    },
  );
}

function convertFile(file) {
  const svg = fs.readFileSync(file, "utf8");
  const out = convertSvg(svg);
  if (out !== svg) fs.writeFileSync(file, out);
}

module.exports = { evenOddToNonZero, convertSvg, convertFile };
