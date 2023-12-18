import * as SaxonJS from 'saxon-js';
import xslJsonItem from './qti2xTo30.sef.json';

const transformqti2xto30 = async (xml) => {
    const transformResult = await SaxonJS.transform(
        {
            stylesheetInternal: xslJsonItem,
            sourceText: xml,
            destination: 'serialized',
        },
        'sync'
    );
    const qti3 = transformResult?.principalResult.toString() || '';
    return qti3;
}

export default transformqti2xto30;