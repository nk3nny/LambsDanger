/*
    Author: joko // Jonas
*/
const fs = require('fs');
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
};
function ParseString(Keys) {
    for (const entry of Keys) {

        const index = stringtableEntries.indexOf(entry.English[0]);
        if (index != -1) {
            console.log(`${entry.$.ID} is a Duplicated string ${stringtableIDs[index]}`);
            failedCount++;
        }
        stringtableIDs.push(entry.$.ID);
        stringtableEntries.push(entry.English[0]);
    }
    
}
getDirFiles("H:\\Git\\ACE3\\addons", "");

while (running != 0) {}
if (failedCount == 0) {
    console.log("No Errors in Found");
} else {
    console.log(`${failedCount} Duplicated Entrys found`)
}

process.exit(failedCount);
