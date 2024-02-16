const fs = require('fs');
const core = require('@actions/core');

if (!fs.existsSync('.hemttout/ci_annotations.txt')) return;

const ci_annotations = fs.readFileSync('.hemttout/ci_annotations.txt', { encoding: 'utf8', flag: 'r' }).split('\n');

for (const annotation of ci_annotations) {
    if (annotation === '') continue;
    const [start_line, end_line, start_column, end_column, type, message, recommendation, file] = annotation.split('||');
    var data = {
        file: file,
        startLine: parseInt(start_line),
        endLine: parseInt(end_line),
        title: recommendation,
    };
    if (start_line === end_line) {
        data.startColumn = start_column;
        data.endColumn = end_column;
    }
    switch (type) {
        case 'error':
            core.error(message, data);
            break;
        case 'warning':
        core.warning(message, data);
            break;
        case 'notice':
        core.notice(message, data);
            break;
        default:
        core.warning(message, data);
            break;
    }
}
