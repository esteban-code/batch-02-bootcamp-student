var { ec } = require("elliptic");
const curve = new ec("secp256k1");
var { keccak_256 } = require("js-sha3");

const llavePrivada =
  "e0eaab0558cac71f5b7efb11668f324000a76ab3843d2e5becfb201cbec97adc";

var publicKey = curve.g.mul(llavePrivada);
publicKey = publicKey.encode("hex");
// console.log("Public Key", publicKey);

var llavePublicaBytes = Buffer.from(publicKey, "hex");
llavePublicaBytes = llavePublicaBytes.slice(1);
// console.log("Array de bytes:", llavePublicaBytes);

var hash = keccak_256(llavePublicaBytes);
console.log("Hash keccack_256", hash);

var addressEthereum = "0x" + hash.slice(-40);
console.log("Address Ethereum", addressEthereum);
