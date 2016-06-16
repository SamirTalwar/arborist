const child_process = require('child_process');
const crypto = require('crypto');
const os = require('os');

let inputFiles = process.argv.slice(2);
let outputFile = os.tmpdir() + '/' + 'arborist-' + crypto.randomBytes(16).readUInt32LE(0) + '.js';
child_process.execFileSync('elm', ['make', '--warn', '--yes', '--output', outputFile].concat(inputFiles));

global.window = global;
let Elm = require(outputFile);
let app = Elm.Main.worker();
