/*
    rn.js
*/

function attachBehaviors(behaviors) {
    for (var selector in behaviors)
        $(selector).each(behaviors[selector]);
}

export {attachBehaviors};
