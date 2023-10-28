var { ethers } = require("hardhat");

async function main() {
  const airdropOneCrossChain = await ethers.deployContract(
    //"AirdropOneCrossChain"
    "contracts/desafios/desafio9/contracts/AirdropOneCrossChain.sol:AirdropOneCrossChain"
  );
  console.log(`Address deployed: ${await airdropOneCrossChain.getAddress()}`);

  // Espera 10 confirmaciones
  var res = await airdropOneCrossChain.waitForDeployment();
  await res.deploymentTransaction().wait(10);

  await hre.run("verify:verify", {
    address: await airdropOneCrossChain.getAddress(),
    constructorArguments: [],
    //contract: "contracts/desafios/desafio9/contracts/AirdropOneCrossChain.sol:AirdropOneCrossChain",
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1; // exitcode quiere decir fallor por error, terminacion fatal
});
