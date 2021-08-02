/*
    rn.js
*/

function attachBehaviors(behaviors) {
    Object.entries(behaviors).forEach(([selector, behavior], index) => {
        document.querySelectorAll(selector).forEach(elm => {
            behavior.call(this, index, elm);
        });
    });
}

export {attachBehaviors};
