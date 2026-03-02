// @noble/hashes/hmac@1.3.2 downloaded from https://ga.jspm.io/npm:@noble/hashes@1.3.2/esm/hmac.js

import{hash as t,exists as s,bytes as e}from"./_assert.js";import{Hash as i,toBytes as o}from"./utils.js";import"@noble/hashes/crypto";class HMAC extends i{constructor(s,e){super();this.finished=false;this.destroyed=false;t(s);const i=o(e);this.iHash=s.create();if("function"!==typeof this.iHash.update)throw new Error("Expected instance of class which extends utils.Hash");this.blockLen=this.iHash.blockLen;this.outputLen=this.iHash.outputLen;const h=this.blockLen;const n=new Uint8Array(h);n.set(i.length>h?s.create().update(i).digest():i);for(let t=0;t<n.length;t++)n[t]^=54;this.iHash.update(n);this.oHash=s.create();for(let t=0;t<n.length;t++)n[t]^=106;this.oHash.update(n);n.fill(0)}update(t){s(this);this.iHash.update(t);return this}digestInto(t){s(this);e(t,this.outputLen);this.finished=true;this.iHash.digestInto(t);this.oHash.update(t);this.oHash.digestInto(t);this.destroy()}digest(){const t=new Uint8Array(this.oHash.outputLen);this.digestInto(t);return t}_cloneInto(t){t||(t=Object.create(Object.getPrototypeOf(this),{}));const{oHash:s,iHash:e,finished:i,destroyed:o,blockLen:h,outputLen:n}=this;t=t;t.finished=i;t.destroyed=o;t.blockLen=h;t.outputLen=n;t.oHash=s._cloneInto(t.oHash);t.iHash=e._cloneInto(t.iHash);return t}destroy(){this.destroyed=true;this.oHash.destroy();this.iHash.destroy()}}
/**
 * HMAC: RFC2104 message authentication code.
 * @param hash - function that would be used e.g. sha256
 * @param key - message key
 * @param message - message data
 */const hmac=(t,s,e)=>new HMAC(t,s).update(e).digest();hmac.create=(t,s)=>new HMAC(t,s);export{HMAC,hmac};

