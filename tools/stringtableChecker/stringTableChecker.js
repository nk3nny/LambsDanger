/*
    Author: joko // Jonas
*/
const fs = require('fs');
const path = require('path');
const xml = require("xml2js");
const { Console } = require('console');

const PREFIX = "Lambs";

var running = 0;
var failedCount = 0;
const stringtableEntries = [];
const projectFiles = [];

function getDirFiles(p, module) {
    var files = fs.readdirSync(p);
    for (const file of files) {
        filePath = path.join(p, file);
        if (fs.lstatSync(filePath).isDirectory()) {
            if (module === "") {
                getDirFiles(filePath, file);
            } else {
                getDirFiles(filePath, module);
            }
        } else {
            if (file.endsWith(".pbo")) continue;
            var data = {
                "path": filePath,
                "module": module
            };
            if (!projectFiles.includes(data))
                projectFiles.push(data);
            if (!file.endsWith(".xml")) continue;
            filePath = path.join(p, file);
            var xmlData = fs.readFileSync(filePath).toString();
            running++;
            xml.parseString(xmlData, function (err, result) {
                for (const entry of result.Project.Package[0].Key) {
                    stringtableEntries.push(entry.$.ID.toLowerCase());
                }
                running--;
            });
        }
    }
};

function CheckStringtables() {
    for (const data of projectFiles) {

        const content = fs.readFileSync(data.path);
        const regex = /LSTRING\((\w+)\)|ELSTRING\((\w+),(\w+)\)/gm;
        let m;

        while ((m = regex.exec(content)) !== null) {
            if (m.index === regex.lastIndex) {
                regex.lastIndex++;
            }

            var strName;
            if (m[1]) {
                strName = `STR_${PREFIX}_${data.module}_${m[1]}`
            } else if (m[2] && m[3]) {
                strName = `STR_${PREFIX}_${m[2]}_${m[3]}`
            }

            if (strName && !stringtableEntries.includes(strName.toLowerCase())) {
                console.log(`Stringtable Entry ${strName} does not exist in ${data.path}`);
                failedCount++;
            }
        }
    }
}

getDirFiles("addons", "");

while (running != 0) {}

CheckStringtables();

if (failedCount == 0) {
    console.log("No Errors in Found");
}

process.exit(failedCount);
