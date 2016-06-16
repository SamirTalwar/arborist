var Elm = require(process.cwd() + '/' + process.argv[2]);

global.window = global;
let app = Elm.Main.worker();
