const path = require('path');
const fs = require('fs');

const PREFIX = "Lambs";

const projectFiles = [];
const prepedFunctions = ["Lambs_main_fnc_fncName", "Lambs_main_fnc_var1", "Lambs_main_fnc_RoundValue"];

let failedCount = 0;

function getDirFiles(p, module) {
    var files = fs.readdirSync(p);
    for (const file of files) {
        if (file.endsWith(".pbo")) continue;
        filePath = path.join(p, file);
        if (fs.lstatSync(filePath).isDirectory()) {
            if (module === "") {
                getDirFiles(filePath, file);
            } else {
                getDirFiles(filePath, module);
            }
        } else {
            var data = {
                "path": filePath,
                "module": module
            };
            if (!projectFiles.includes(data))
                projectFiles.push(data);
            getFunctions(filePath, module);
        }
    }
};

function getFunctions(file, module) {
    var data = fs.readFileSync(file);
    var regex = /PREP\((\w+)\)|SUBPREP\((\w+),(\w+)\);|DFUNC\((\w+)\)/gm;
    let m;
    while ((m = regex.exec(data)) !== null) {
        // This is necessary to avoid infinite loops with zero-width matches
        if (m.index === regex.lastIndex) {
            regex.lastIndex++;
        }

        // The result can be accessed through the `m`-variable.
        m.forEach((match, groupIndex) => {
            if (match && groupIndex != 0 && groupIndex != 2 && match != "var1" && match != "fncName") {
                prepedFunctions.push(`${PREFIX}_${module}_fnc_${match}`)
            }
        });
    }
}

function CheckFunctions() {
    for (const data of projectFiles) {
        var content = fs.readFileSync(data.path);
        var regex = /FUNC\((\w+)\)|EFUNC\((\w+),(\w+)\)/gm;
        let m;
        while ((m = regex.exec(content)) !== null) {
            // This is necessary to avoid infinite loops with zero-width matches
            if (m.index === regex.lastIndex) {
                regex.lastIndex++;
            }
            if (m[1]) {
                var fncName = `${PREFIX}_${data.module}_fnc_${m[1]}`;
                if (!prepedFunctions.includes(fncName)) {
                    console.log(`Use of not Existing Function: ${fncName} in ${data.path}`)
                    failedCount++;
                }
            } else if (m[3] && m[4]) {
                var fncName = `${PREFIX}_${m[3]}_fnc_${m[4]}`;
                if (!prepedFunctions.includes(fncName)) {
                    console.log(`Use of not Existing Functions: ${fncName} in ${data.path}`)
                    failedCount++;
                }
            }
        }
    }
}

getDirFiles("addons", "");
CheckFunctions();
process.exit(failedCount);