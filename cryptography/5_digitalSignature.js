var {
  hash,
  createIdentity,
  sign,
  recover, // recuperas el address de ethereum
  recoverPublicKey,
} = require("eth-crypto");

// Creando las credenciales de Alice
const alice = createIdentity(); // Llave publica + llave privada

// Alice escribe un mensaje
const mensaje = "Este mensaje fue escrito por Alice";
const mensajeHasheado = hash.keccak256(mensaje);

// Alice firma el mensaje hasheado
const firmaDigital = sign(alice.privateKey, mensajeHasheado);
console.log(firmaDigital);

// Recuperando Llave publica
var llavePublica = recoverPublicKey(firmaDigital, mensajeHasheado);
console.log("Recover Public Key", llavePublica);
console.log("Llave Publica Alice", alice.publicKey);
