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

const regex = /LSTRING\((\w+)\)|ELSTRING\((\w+),(\w+)\)/gm;
const commentRegex = /\/\*[\s\S]*?\*\/|([^\\:]|^)\/\/.*$/gm;

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

        let content = fs.readFileSync(data.path).toString();
        content = content.replace(commentRegex, '');
        let match;

        while ((match = regex.exec(content)) !== null) {
            if (match.index === regex.lastIndex) {
                regex.lastIndex++;
            }

            var strName;
            if (match[1]) {
                strName = `STR_${PREFIX}_${data.module}_${match[1]}`
            } else if (match[2] && match[3]) {
                strName = `STR_${PREFIX}_${match[2]}_${match[3]}`
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
