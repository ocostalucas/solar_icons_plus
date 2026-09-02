// Font generation wrapper for Windows compatibility.
const fs = require("fs");
const path = require("path");
const { generateFonts } = require("fantasticon");

const inputDir = process.argv[2];
const outputDir = process.argv[3];
const fontName = process.argv[4];

if (!inputDir || !outputDir || !fontName) {
  console.error("Usage: node scripts/generate_font.js <input> <output> <name>");
  process.exit(1);
}

fs.mkdirSync(outputDir, { recursive: true });

const config = {
  inputDir: inputDir.split(path.sep).join("/"),
  outputDir: outputDir.split(path.sep).join("/"),
  name: fontName,
  fontTypes: ["ttf"],
  assetTypes: ["json"],
  normalize: false,
  fontHeight: 1024,
};

const originalJoin = path.join;
path.join = function (...args) {
  return originalJoin.apply(this, args).split(path.sep).join("/");
};

generateFonts(config)
  .then(() => {
    path.join = originalJoin;
    console.log(`Generated font: ${fontName}.ttf`);
  })
  .catch((error) => {
    path.join = originalJoin;
    console.error("Font generation failed:", error.message || error);
    process.exit(1);
  });
