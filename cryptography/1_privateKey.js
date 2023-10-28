var { ethers } = require("hardhat");
const Wallet = ethers.Wallet.createRandom();
console.log("Llave private Ethers.js", Wallet.privateKey);

const mnemoic = ethers.Wallet.createRandom().mnemonic;
console.log(mnemoic.phrase);
const Wallet2 = ethers.Wallet.fromPhrase(mnemoic.phrase);
console.log("Llave privada (mnemonic)", Wallet2.privateKey);

// ec: elliptic curve
var { ec } = require("elliptic");
const curve = new ec("secp256k1");
const keyPair = curve.genKeyPair();
console.log("Llave privada (ec):", keyPair.getPrivate("hex"));
