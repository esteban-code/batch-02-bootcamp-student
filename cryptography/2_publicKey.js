var { ec } = require("elliptic");
const curve = new ec("secp256k1");

const llavePrivada =
  "e0eaab0558cac71f5b7efb11668f324000a76ab3843d2e5becfb201cbec97adc";

// Llave publica = (Llave privada * G) mod p;
// el 'mod' se hace internamente dentro de la librería
const publicKey = curve.g.mul(llavePrivada);

console.log("Public Key", publicKey.encode("hex"));
// Versión no compacta de llave pública
// 04 9d4b0a9f4cbdeeb35a328a71d19d0f184665017b6c4a77b3e23e8edcbc850921da6a7859df1797ed2dbda698cbd6f16b62be58fd85d05b1bbb3e9547c8f81127
//  X 9d4b0a9f4cbdeeb35a328a71d19d0f184665017b6c4a77b3e23e8edcbc850921
//  Y                                                                 da6a7859df1797ed2dbda698cbd6f16b62be58fd85d05b1bbb3e9547c8f81127
console.log("Public Key (X)", publicKey.getX().toString(16));
console.log("Public Key (Y)", publicKey.getY().toString(16));
