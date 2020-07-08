/*
    Author: joko // Jonas
*/
const fs = require('fs');
const EOL = require('os').EOL;
const path = require('path');
const xml = require("xml2js");
const { Console } = require('console');
const { fail } = require('assert');

const PREFIX = "Lambs";

var running = 0;
var failedCount = 0;
const stringtableIDs = [];
const stringtableEntries = [];
const projectFiles = [];

fs.writeFileSync("duplicated.log", "");

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
                if (result.Project.Package[0].Key) {
                    ParseString(result.Project.Package[0].Key);
                } else if (result.Project.Package[0].Container) {
                    for (const entry of result.Project.Package[0].Container) {
                        ParseString(entry.Key);
                    }
                }
                running--;
            });
        }
    }
}

function ParseString(Keys) {
    for (const entry of Keys) {
        for (const key in entry) {
            if (key != "$" && entry.hasOwnProperty(key)) {
                const element = entry[key][0];
                const index = stringtableEntries.indexOf(element);
                if (index != -1) {
                    const log = `${entry.$.ID} is a Duplicated string ${stringtableIDs[index]} : ${key}`;
                    fs.appendFileSync("duplicated.log", log + EOL);
                    console.log(log);
                    failedCount++;
                }
                stringtableIDs.push(entry.$.ID);
                stringtableEntries.push(element);
            }
        }
    }
}

getDirFiles("addons", "");

while (running != 0) {}
if (failedCount == 0) {
    console.log("No Errors in Found");
} else {
    console.log(`${failedCount} Duplicated Entrys found`)
}

process.exit(failedCount);
