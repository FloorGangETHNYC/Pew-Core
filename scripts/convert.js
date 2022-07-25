//http://www.hacksparrow.com/base64-encoding-decoding-in-node-js.html
let fs = require("fs");

// function to encode file data to base64 encoded string
function base64_encode(filepath) {
  // read binary data
  let bitmap = fs.readFileSync(filepath);
  // convert binary data to base64 encoded string
  return new Buffer.from(bitmap).toString("base64");
}

// function to create file from base64 encoded string
function base64_decode(base64str, file) {
  // create buffer object from base64 encoded string, it is important to tell the constructor that the string is base64 encoded
  let bitmap = new Buffer.from(base64str, "base64");
  // write buffer to file
  fs.writeFileSync(file, bitmap);
  console.log("******** File created from base64 encoded string ********");
}

function main() {
  // get all svg files in data directory
  let files = fs.readdirSync("./data/dynamic");
  let output = "";
  // console.log("🚀 | main | files", files);
  let counts = {};
  for (let f of files) {
    let varname = f.split("_")[0];

    if (varname in counts) {
      counts[varname] += 1;
    } else {
      counts[varname] = 0;
    }

    varname = varname + "[" + counts[varname] + "]";
    console.log("🚀 | main | varname", varname);
    // convert image to base64 encoded string
    let base64str = base64_encode(`./data/dynamic/${f}`);
    console.log(base64str);
    output += `${varname}="data:image/svg+xml;base64,` + base64str + `";\n`;
    // convert base64 string back to image
    // base64_decode(base64str, "copy_salvarDocumento.png");
  }
  // Write to txt file
  fs.writeFileSync("output.txt", output);
}

main();
