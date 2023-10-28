var { encryptWithPublicKey, decryptWithPrivateKey } = require("eth-crypto");
var { ec } = require("elliptic");

// Bob necesita tener credenciales
const curve = new ec("secp256k1");
const bobKeyPair = curve.genKeyPair(); // Llave publica y llave privada

// console.log(bobKeyPair.getPublic("hex"));
// console.log(bobKeyPair.getPrivate("hex"));

async function encrypt() {
  // Enviado por alice
  const message = "Hola Bob. Este es un mensaje secreto";

  const mensajeEncriptado = await encryptWithPublicKey(
    bobKeyPair.getPublic("hex"),
    message
  );

  console.log("Enviando el mensaje encryptado por el Internet...");

  // Bob
  const mensajeDesencriptado = await decryptWithPrivateKey(
    bobKeyPair.getPrivate("hex"),
    mensajeEncriptado
  );

  console.log("Mensaje secreto de Alice", mensajeDesencriptado);
}

encrypt();
