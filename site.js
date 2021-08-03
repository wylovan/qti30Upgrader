/* 
 * site.js
 */

import * as fflate from 'https://cdn.skypack.dev/fflate?min';
import {attachBehaviors} from './rn.js';
//console.log(SaxonJS.getProcessorInfo());
//console.log('fflate', fflate);

const domParser = new DOMParser(),
    xmlSerializer = new XMLSerializer(),
    inputFiles = document.getElementById('inputFiles'),
    inputShowInPage = document.getElementById('inputShowInPage'),
    inputCreateZip = document.getElementById('inputCreateZip');

let results = document.getElementById('results'),
    xslJson = null;

fetch('qti2xTo30.sef.json')
    .then(res => res.json())
    .then(data => {
        xslJson = data;
        console.log('Stylesheet read from SEF.')
    })
    .catch(err => {
        console.log('SEF not available. Getting XSL...');
        const loc = window.location;
        SaxonJS.getResource({
            location: `${loc.protocol}//${loc.host}${loc.pathname.replace(/^(.*\/).*$/, '$1')}qti2xTo30.xsl`,
            type: 'xml'
        })
        .then(doc => {
            xslJson = SaxonJS.compile(doc);
            console.log('Stylesheet compiled from XSL.')
        })
        .catch(err => {
            console.log('Error getting XSL resource.', err);
            alert('No XSL available!')
        });
    });

function transform(txt) {
    return SaxonJS.transform({
            stylesheetInternal: xslJson,
            sourceText: txt,
            destination: 'serialized'
        }, 'async')
        .then (output => {
            return output.principalResult;
        })
        .catch(err => {
            console.log('ERROR:', err);
            return txt;
        });
}

function showInPage(fileName, content) {
    let result = document.createElement('div'),
        h2 = document.createElement('h2'),
        pre = document.createElement('pre');
    h2.append(fileName);
    if (content.code) {
        result.classList.add('transformerror');
        pre.append(content.code + ': ' + content.message);
    }
    else
        pre.append(content);
    result.append(h2, pre);
    results.append(result);
}

function zipFiles(values) {
    const zipOut = [];
    const zipFile = new fflate.Zip();
    zipFile.ondata = (err, dat, final) => {
        if (err) throw err;
        zipOut.push(dat);
        if (final) {
            const blob = new Blob(zipOut, { type: 'application/zip' });
            var fileName = 'qti-' + new Date().toISOString() + '.zip';
            var tempEl = document.createElement("a");
            document.body.appendChild(tempEl);
            tempEl.style = "display: none";
            var url = window.URL.createObjectURL(blob);
            tempEl.href = url;
            tempEl.download = fileName;
            tempEl.click();
            window.URL.revokeObjectURL(url);
        }
    }

    values.forEach((v, i) => {
        if (v !== undefined) {
            const val = fflate.strToU8(v.result),
                defl = new fflate.AsyncZipDeflate(v.filename, { level: 9 });
            zipFile.add(defl);
            defl.push(val, true);
        }
    });
    console.log('END');
    zipFile.end();
}

function processFiles() {
    results.innerHTML = '';
    let promises = [];
    for (var i = 0; i < inputFiles.files.length; i++) {
        let file = inputFiles.files[i];
        console.log('Processing file: ', file.name);
        promises.push(
            file.text()
                .then(txt => {               
                    return transform(txt);
                })
                .then(transformed => {
                    if (inputShowInPage.checked)
                        showInPage(file.name, transformed);
                    return {
                        filename: file.name,
                        result: transformed
                    };
                })
                .catch(err => {
                    console.log('ERROR: ', err);
                    if (inputShowInPage.checked)
                        showInPage(file.name, err);
                })
        );
    }
    if (inputCreateZip.checked)
        Promise.all(promises).then(zipFiles);
}

attachBehaviors({
    'form#uploadForm': function(idx, elm) {
        elm.addEventListener('submit', function(evt) {
            evt.preventDefault();
            processFiles();
        });
    }
});
