# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "ethers" # @6.16.0
pin "#lib.esm/crypto/crypto.js", to: "#lib.esm--crypto--crypto.js.js" # @6.16.0
pin "#lib.esm/providers/provider-ipcsocket.js", to: "#lib.esm--providers--provider-ipcsocket.js.js" # @6.16.0
pin "#lib.esm/providers/ws.js", to: "#lib.esm--providers--ws.js.js" # @6.16.0
pin "#lib.esm/utils/base64.js", to: "#lib.esm--utils--base64.js.js" # @6.16.0
pin "#lib.esm/utils/geturl.js", to: "#lib.esm--utils--geturl.js.js" # @6.16.0
pin "#lib.esm/wordlists/wordlists.js", to: "#lib.esm--wordlists--wordlists.js.js" # @6.16.0
pin "@adraffy/ens-normalize", to: "@adraffy--ens-normalize.js" # @1.10.1
pin "@noble/curves/secp256k1", to: "@noble--curves--secp256k1.js" # @1.2.0
pin "@noble/hashes/crypto", to: "@noble--hashes--crypto.js" # @1.3.2
pin "@noble/hashes/hmac", to: "@noble--hashes--hmac.js" # @1.3.2
pin "@noble/hashes/pbkdf2", to: "@noble--hashes--pbkdf2.js" # @1.3.2
pin "@noble/hashes/ripemd160", to: "@noble--hashes--ripemd160.js" # @1.3.2
pin "@noble/hashes/scrypt", to: "@noble--hashes--scrypt.js" # @1.3.2
pin "@noble/hashes/sha256", to: "@noble--hashes--sha256.js" # @1.3.2
pin "@noble/hashes/sha3", to: "@noble--hashes--sha3.js" # @1.3.2
pin "@noble/hashes/sha512", to: "@noble--hashes--sha512.js" # @1.3.2
pin "@noble/hashes/utils", to: "@noble--hashes--utils.js" # @1.3.2
pin "aes-js" # @4.0.0
