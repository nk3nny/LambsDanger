const fs = require('fs');
const fsp = fs.promises;
const spawn = require('child_process').spawn;

async function exec(command, params) {
  return new Promise((resolve, reject) => {
    let stdout = '';
    let stderr = '';

    let process = spawn(command, params);

    process.stdout.on('data', (data) => {
      if (data == undefined)
        return;

      stdout += data.toString();
    });

    process.stderr.on('data', (data) => {
      stderr += data;
    });

    process.on('close', (code) => {
      if (code == 0) {
        return resolve(stdout);
      }
      return resolve(stdout);
    });
  });
}

async function main() {
    const filePath = "addons/main/script_version.hpp";
    let version = await fsp.readFile(filePath, { encoding: 'utf-8' });
    const gitVersion = await exec('git', ['rev-list', '--count', 'HEAD']);
    version = version.replace("#define BUILD 0", "#define BUILD " + gitVersion);
    await fsp.writeFile(filePath, version);
}


main();
