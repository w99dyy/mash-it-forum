// #lib.esm/utils/base64.js@6.16.0 downloaded from https://ga.jspm.io/npm:ethers@6.16.0/lib.esm/utils/base64-browser.js

import{g as t}from"../../_/8s0kXjmT.js";import"../../_/B19P9EpB.js";function r(r){r=atob(r);const o=new Uint8Array(r.length);for(let t=0;t<r.length;t++)o[t]=r.charCodeAt(t);return t(o)}function o(r){const o=t(r);let n="";for(let t=0;t<o.length;t++)n+=String.fromCharCode(o[t]);return btoa(n)}export{r as decodeBase64,o as encodeBase64};

