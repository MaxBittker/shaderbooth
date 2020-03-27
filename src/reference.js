let fs = require("fs");

let prefix = fs.readFileSync(__dirname + "/prefix.glsl").toString();

var CodeMirror = require("codemirror/lib/codemirror");
require("codemirror/mode/clike/clike");
require("codemirror/addon/runmode/runmode");
require("codemirror/addon/runmode/colorize");

let reference = document.getElementById("reference");
prefix = prefix.replace("precision mediump float;\n", "");
prefix = prefix.replace(/ *\{[^}]*\} */g, "{}");
prefix = prefix.replace(/ *\{[^}]*\} */g, "{}");
prefix = prefix.replace(/ *\{[^}]*\} */g, "{}");
prefix = prefix.replace(/ *\{[^}]*\} */g, "{}");
prefix = prefix.replace(/ *\{[^}]*\} */g, "{}");
prefix = prefix.replace(/ *\{[^}]*\} */g, "{}");
prefix = prefix.replace(
  `{}else{}
  return rgb;
}`,
  "{}"
);

prefix = prefix.replace(
  `{}
  }
  return v;
}`,
  "{}"
);
prefix = prefix.replace(
  `{}
  }
  return v;
}`,
  "{}"
);
prefix = prefix.replace(
  `{}
  }
  return v;
}`,
  "{}"
);
prefix = prefix.replace(
  `{}
  }
  return v;
}`,
  "{}"
);
prefix = prefix.replace(/\/\/ INTERNAL\n.*\n/g, "");
prefix = prefix.replace(/\n\n/g, "\n");
prefix = prefix.replace(/\n\n/g, "\n");
prefix = prefix.replace(/\/\/ SPACER\n/g, "\n");

CodeMirror.runMode(prefix, "x-shader/x-fragment", reference);
