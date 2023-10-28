const { ethers, upgrades } = require("hardhat");

// Address Contrato Proxy: 0xF8B71dD7df036a256150D5bb5998E3289beE5E70
async function main() {
  // obtener el código del contrato
  var UpgradeableToken = await ethers.getContractFactory("LMTokenUpgradeable");

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

async function upgrade() {
  const ProxyAddress = "0xF8B71dD7df036a256150D5bb5998E3289beE5E70";
  const LMTokenUpgradeableV2 = await ethers.getContractFactory(
    "LMTokenUpgradeable"
  );
  const lmTokenUpgradeableV2 = await upgrades.upgradeProxy(
    ProxyAddress,
    LMTokenUpgradeableV2
  );

  // esperar unas confirmaciones

  var implV2 = await upgrades.erc1967.getImplementationAddress(ProxyAddress);
  console.log(`Address Proxy: ${ProxyAddress}`);
  console.log(`Address Impl V2: ${implV2}`);

  await hre.run("verify:verify", {
    address: implV2,
    constructorArguments: [],
  });
}

upgrade().catch((error) => {
  console.error(error);
  process.exitCode = 1; // nodeJs | 1 significa que falló la operación
});
