const { ethers, upgrades } = require("hardhat");

async function upgrade() {
  const ProxyAddress = "0xAB95222Fb6268eabc114fd2e32808FaD1143C3c0";//cambiar el address del proxy obtenido en script deployProxy.js
  const EAGTokenUpgradeableV2 = await ethers.getContractFactory(
    "EAGTokenUpgradeable"
  );
  const eagTokenUpgradeableV2 = await upgrades.upgradeProxy(
    ProxyAddress,
    EAGTokenUpgradeableV2
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