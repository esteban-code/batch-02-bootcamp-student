var { ethers } = require("hardhat");
require("dotenv").config();

function buildMessageData(
  name,
  verifyingContract,
  owner,
  spender,
  value,
  nonce,
  deadline
) {
  const domain = {
    name,
    version: "1",
    chainId: 80001,
    verifyingContract,
  };

  const types = {
    Permit: [
      {
        name: "owner",
        type: "address",
      },
      {
        name: "spender",
        type: "address",
      },
      {
        name: "value",
        type: "uint256",
      },
      {
        name: "nonce",
        type: "uint256",
      },
      {
        name: "deadline",
        type: "uint256",
      },
    ],
  };
  const values = {
    owner,
    spender,
    value,
    nonce,
    deadline,
  };
  return [domain, types, values];
}

async function main() {
  ////////////////////////// VARIABLES A CAMBIAR ///////////////////////
  // Address del contrato que implementa ERC20Permit de Remix
  const tokenAddress = "0x89F5e422D688F2fe9475ea3A839183353bB26892";
  // Address del Gastador que recibirá el allowance del Propietario
  const spenderAddress = "0xA3a786FF773524f2aff0edED90230616A3a26de1";
  //////////////////////////////////////////////////////////////////////

  // owner: Es el mismo que el Propietario
  // Este valor sale del archivo hardhat.config.js de la llave accounts
  const [owner] = await ethers.getSigners();
  const ownerAddress = await owner.getAddress();

  // provider
  // El proveedor viene del contexto cuando se ejecuta el comando
  const provider = ethers.provider;

  // contract
  // Aquí se crea una instancia del contrato que implementa ERC20Permit
  // Se hacen dos llamados a dicho contrato: name() y nonces()
  // Ambos se utilizan para crear el mensaje que se firmará
  const abi = [
    "function nonces(address account) public view returns(uint256)",
    "function name() public view returns(string memory)",
  ];
  const tokenContract = new ethers.Contract(tokenAddress, abi, provider);
  const tokenName = await tokenContract.name();

  // nonce
  const nonce = await tokenContract.nonces(ownerAddress);

  // Se define el valor a gastar
  const amount = ethers.parseEther("1000").toString();
  // Se define el deadline (fecha de expiración de la firma)
  const deadline = Math.round(Date.now() / 1000) + 60 * 10; // 10 min

  // Se crea el mensaje que se firmará siguiendo el estándar ERC-2612
  // Para hacer funcionar esta firma en otra chain, se debe cambiar el chainId en domain
  const [domain, types, values] = buildMessageData(
    tokenName,
    tokenAddress,
    ownerAddress,
    spenderAddress,
    amount,
    nonce.toString(),
    deadline
  );

  // Se firma el mensaje usando la llave privada del Propietario
  // domain, types y values son los parámetros que se pasan al contrato
  // Está basado en el estándar EIP-712. En el fondo, este estándar
  // Busca firmar una información estructurada, en este caso, el mensaje de dar allowance
  var sigData = await owner.signTypedData(domain, types, values);
  // Se separa la firma en sus componentes v, r y s
  var splitSignature = ethers.Signature.from(sigData);
  var { v, r, s } = splitSignature;

  console.log("ownerAddress:", ownerAddress);
  console.log("spenderAddress:", spenderAddress);
  console.log("value:", amount);
  console.log("deadline:", deadline);
  console.log("v:", v);
  console.log("r:", r);
  console.log("s:", s);

  // Esto es lo que también hará el contrato que implementa ERC20Permit
  // Es decir, el contrato extraerá el address del mensaje firmado para
  // compararlo con el address del Propietario. De ser iguales, procederá
  // a modificar el mapping de allowances.
  const recovered = await ethers.verifyTypedData(
    domain,
    types,
    values,
    splitSignature
  );
  console.log("Address recuperada de firma:", recovered);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
