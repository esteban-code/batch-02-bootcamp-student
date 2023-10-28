const { ethers, upgrades } = require("hardhat");

// Address Contrato Proxy: 0xAB95222Fb6268eabc114fd2e32808FaD1143C3c0
async function main() {
  // obtener el código del contrato
  var UpgradeableToken = await ethers.getContractFactory("EAGTokenUpgradeable");

  // publicar el proxy
  var upgradeableToken = await upgrades.deployProxy(UpgradeableToken, [], {
    kind: "uups",
  });

  // esperar a que se confirme el contrato - 5 confirmaciones
  var tx = await upgradeableToken.waitForDeployment();
  await tx.deploymentTransaction().wait(5);

  // obtenemos el address de implementación
  var implementationAdd = await upgrades.erc1967.getImplementationAddress(
    await upgradeableToken.getAddress()
  );

  console.log(`Address del Proxy es: ${await upgradeableToken.getAddress()}`);
  console.log(`Address de Impl es: ${implementationAdd}`);

  // hacemos la verificación del address de implementación
  await hre.run("verify:verify", {
    address: implementationAdd,
    constructorArguments: [],
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1; // nodeJs | 1 significa que falló la operación
});