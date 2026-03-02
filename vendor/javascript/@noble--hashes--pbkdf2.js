// @noble/hashes/pbkdf2@1.3.2 downloaded from https://ga.jspm.io/npm:@noble/hashes@1.3.2/esm/pbkdf2.js

import{hash as t,number as n}from"./_assert.js";import{hmac as e}from"./hmac.js";import{checkOpts as o,toBytes as s,createView as r,asyncLoop as c}from"./utils.js";import"@noble/hashes/crypto";function pbkdf2Init(r,c,u,a){t(r);const i=o({dkLen:32,asyncTick:10},a);const{c:p,dkLen:d,asyncTick:f}=i;n(p);n(d);n(f);if(p<1)throw new Error("PBKDF2: iterations (c) should be >= 1");const l=s(c);const y=s(u);const k=new Uint8Array(d);const b=e.create(r,l);const I=b._cloneInto().update(y);return{c:p,dkLen:d,asyncTick:f,DK:k,PRF:b,PRFSalt:I}}function pbkdf2Output(t,n,e,o,s){t.destroy();n.destroy();o&&o.destroy();s.fill(0);return e}
/**
 * PBKDF2-HMAC: RFC 2898 key derivation function
 * @param hash - hash function that would be used e.g. sha256
 * @param password - password from which a derived key is generated
 * @param salt - cryptographic salt
 * @param opts - {c, dkLen} where c is work factor and dkLen is output message size
 */function pbkdf2(t,n,e,o){const{c:s,dkLen:c,DK:u,PRF:a,PRFSalt:i}=pbkdf2Init(t,n,e,o);let p;const d=new Uint8Array(4);const f=r(d);const l=new Uint8Array(a.outputLen);for(let t=1,n=0;n<c;t++,n+=a.outputLen){const e=u.subarray(n,n+a.outputLen);f.setInt32(0,t,false);(p=i._cloneInto(p)).update(d).digestInto(l);e.set(l.subarray(0,e.length));for(let t=1;t<s;t++){a._cloneInto(p).update(l).digestInto(l);for(let t=0;t<e.length;t++)e[t]^=l[t]}}return pbkdf2Output(a,i,u,p,l)}async function pbkdf2Async(t,n,e,o){const{c:s,dkLen:u,asyncTick:a,DK:i,PRF:p,PRFSalt:d}=pbkdf2Init(t,n,e,o);let f;const l=new Uint8Array(4);const y=r(l);const k=new Uint8Array(p.outputLen);for(let t=1,n=0;n<u;t++,n+=p.outputLen){const e=i.subarray(n,n+p.outputLen);y.setInt32(0,t,false);(f=d._cloneInto(f)).update(l).digestInto(k);e.set(k.subarray(0,e.length));await c(s-1,a,(()=>{p._cloneInto(f).update(k).digestInto(k);for(let t=0;t<e.length;t++)e[t]^=k[t]}))}return pbkdf2Output(p,d,i,f,k)}export{pbkdf2,pbkdf2Async};

