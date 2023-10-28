var { ethers } = require("hardhat");

async function main() {
  var _collectionName = "Lee Marreros Colection NFTs";
  var _collectionSymbol = "LMRRCLNFTS";

  var contratoNft = await ethers.deployContract("MiPrimerNft", [
    _collectionName,
    _collectionSymbol,
  ]);
  var contratoAddress = await contratoNft.getAddress();
  console.log(`Address Contrato es ${contratoAddress}`);

  // Esperar una cantidad N de confirmaciones
  var res = await contratoNft.waitForDeployment();
  await res.deploymentTransaction().wait(10);

  await hre.run("verify:verify", {
    address: contratoAddress,
    constructorArguments: [_collectionName, _collectionSymbol],
  });

  // $ npx hardhat --network mumbai run script/deployNft.js
}

main();
