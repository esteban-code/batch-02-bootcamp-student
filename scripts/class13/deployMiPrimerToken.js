var { ethers } = require("hardhat");

async function main() {
  var name = "Mi Primer Token";
  var symbol = "MPRTKN";
  //const miPrimerToken = await ethers.deployContract("MiPrimerTokenCrossChain", [
  const miPrimerToken = await ethers.deployContract("contracts/class13/MiPrimerToken.sol:MiPrimerTokenCrossChain", [
    name,
    symbol,
  ]);
  console.log(`Address deployed: ${await miPrimerToken.getAddress()}`);

  // Espera 10 confirmaciones
  var res = await miPrimerToken.waitForDeployment();
  await res.deploymentTransaction().wait(10);

  await hre.run("verify:verify", {
    address: await miPrimerToken.getAddress(),
    constructorArguments: [name, symbol],
    //contract: "contracts/class13/MiPrimerToken.sol:MiPrimerTokenCrossChain",
  });
}

main()
.catch((error) => {
  console.error(error);
  process.exitCode = 1; // exitcode quiere decir fallor por error, terminacion fatal
});
