const { ethers } = require("hardhat");

async function main() {
  var [owner, alice, bob] = await ethers.getSigners();

  var contract = await ethers.deployContract("BBTKN", []);

  var contractAddress = await contract.getAddress();
  console.log(`Address del contrato ${contractAddress}`);

  var res = await contract.waitForDeployment();
  await res.deploymentTransaction().wait(10);

  await hre.run("verify:verify", {
    address: contractAddress,
    constructorArguments: [],
  });
}

main();
