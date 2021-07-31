import {attachBehaviors} from './rn.js';
import * as fflate from 'https://cdn.skypack.dev/fflate?min'
//console.log(SaxonJS.getProcessorInfo());
console.log('fflate', fflate);

const domParser = new DOMParser(),
    xmlSerializer = new XMLSerializer();


let results = $('#results'),
    xslJson = null;

$.getJSON('qti2xTo30.sef.json')
    .fail(function() {
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
    })
    .done(function(data) {
        console.log('Stylesheet read from SEF.')
        xslJson = data;
    });


function transform(doc) {
    return SaxonJS.transform({
            stylesheetInternal: xslJson,
            sourceNode: doc,
            destination: 'document'
        }, 'async')
        .then (output => {
            return output.principalResult;
        })
        .catch(err => {
            console.log('ERROR:', err);
        });
}

attachBehaviors({
    'form#uploadForm': function(idx, elm) {
        let form = $(elm),
            submit = document.getElementById('inputFiles');

        form.submit(function(evt) {
            evt.preventDefault();
            results.empty();
            let promises = [];
            for (var i = 0; i < submit.files.length; i++) {
                let file = submit.files[i],
                    result = $(document.createElement('div')),
                    pre = $(document.createElement('pre'));
                result.append('<h2>' + file.name + '</h2>', pre);
                results.append(result);
                promises.push(
                    file.text()
                        .then(txt => {
                            let doc = domParser.parseFromString(txt, 'text/xml'),
                                errCount = doc.getElementsByTagName('parsererror').length
                            if (errCount !== 0) {
                                result.addClass('parsererror');
                                return doc;
                            }
                            else
                                return transform(doc);
                        })
                        .then(transformed => {
                            const serialized = xmlSerializer.serializeToString(transformed);
                            pre.text(serialized);
                            return {
                                filename: file.name,
                                result: serialized
                            };
                        })
                );
            }
            Promise.all(promises)
                .then(values => {
                    const zipOut = [];
                    const zipFile = new fflate.Zip();
                    zipFile.ondata = (err, dat, final) => {
                        console.log('ONDATA', final, dat);
                        if (err) throw err;
                        zipOut.push(dat);
                        if (final) {
                            console.log('FINAL');

                            const blob = new Blob(zipOut, { type: 'application/zip' });

                        	var fileName = 'qti-' + new Date().toISOString() + '.zip';
                    		var tempEl = document.createElement("a");
                        	document.body.appendChild(tempEl);
                        	tempEl.style = "display: none";
                            var url = window.URL.createObjectURL(new Blob(zipOut, {type : 'application/zip'}));
                            tempEl.href = url;
                            tempEl.download = fileName;
                            tempEl.click();
                    		window.URL.revokeObjectURL(url);
                        }
                    }

                    values.forEach((v, i) => {
                        const val = fflate.strToU8(v.result),
                            defl = new fflate.AsyncZipDeflate(v.filename, { level: 9 });
                        zipFile.add(defl);
                        console.log('SIZE: ' + values.length, '; I: ' + i)
                        if (i == values.length - 1) {
                            console.log('PUSHING TRUE', fflate.strFromU8(val));
                            defl.push(val, true);
                        }
                        else {
                            console.log('PUSHING', fflate.strFromU8(val));
                            defl.push(val);
                        }
                    });
//                    for (var i = 0; i < values.length; i++) {
//                        const v = values[i];
//                        const defl = new fflate.AsyncZipDeflate(v.filename, { level: 9 });
//                        zipFile.add(defl);
//                        console.log('SIZE: ' + values.length, '; I: ' + i)
//                        if (i == values.length - 1) {
//                            console.log('HERE');
//                            defl.push(fflate.strToU8(v.result), true);
//                        }
//                        else {
//                            console.log('PUSHING');
//                            defl.push(fflate.strToU8(v.result));
//                        }
//                    }
                    console.log('END');
                    zipFile.end();
                });
        });
    }
});
