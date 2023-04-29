const path = require("path");
const esbuild = require("esbuild");

function printResult(result) {
  Object.keys(result).forEach((fileName) => {
    // convert to kilobyte
    const fileSize = result[fileName].bytes / 1000;
    console.log(`${fileName} => ${fileSize} Kb`);
  });
}

const codeResult = esbuild.buildSync({
  minify: true,
  bundle: true,
  keepNames: false,
  metafile: true,
  outfile: path.resolve(__dirname, "./dist/a.js"),
  sourcemap: true,
  platform: "browser",
  target: "es6",
  entryPoints: ["./src/index.js"],
});

printResult(codeResult?.metafile?.outputs || {});
