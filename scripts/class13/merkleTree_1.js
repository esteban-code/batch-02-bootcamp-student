const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");
const { ethers } = require("hardhat");

var merkleTree, raiz;
function construirMerkleTree() {
  var hojas = [1, 2, 3, 4, 5, 6, 7, 8];

  merkleTree = new MerkleTree(hojas, keccak256, { sortPairs: true });
  raiz = merkleTree.getHexRoot();

  console.log(merkleTree.toString());
  console.log(raiz);
}

var hojaABuscarPrueba, pruebasDeLaHoja;
function construyendoPruebas() {
  hojaABuscarPrueba = 4;
  pruebasDeLaHoja = merkleTree.getHexProof(hojaABuscarPrueba);
  console.log(pruebasDeLaHoja);
}

function verificandoPrueba() {
  var pertenece = merkleTree.verify(pruebasDeLaHoja, hojaABuscarPrueba, raiz);
  console.log(pertenece);
}

construirMerkleTree();
construyendoPruebas();
verificandoPrueba();
