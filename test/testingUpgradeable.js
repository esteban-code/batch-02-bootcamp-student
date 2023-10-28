const { expect } = require("chai");

describe("Upgradeable token", () => {
  var Upgradeabletoken, Upgradeabletoken2, upgradeabletoken, upgradeabletoken2;

  describe("Set Up", () => {
    it("Publicando los contarto inteligentes", async () => {
      Upgradeabletoken = await hre.ethers.getContractFactory(
        "UpgradeableToken"
      );
      upgradeabletoken = await hre.upgrades.deployProxy(Upgradeabletoken, {
        kind: "uups",
      });

      var implementationAddress =
        await hre.upgrades.erc1967.getImplementationAddress(
          upgradeabletoken.target
        );

      console.log(`El address del Proxy es ${upgradeabletoken.target}`);
      console.log(`El address de Implementation es ${implementationAddress}`);

      Upgradeabletoken2 = await hre.ethers.getContractFactory(
        "UpgradeableToken2"
      );
      upgradeabletoken2 = await hre.upgrades.upgradeProxy(
        upgradeabletoken,
        Upgradeabletoken2
      );

      var implementationAddress2 =
        await hre.upgrades.erc1967.getImplementationAddress(
          upgradeabletoken.target
        );
      console.log(
        `El address de Implementation V2 es ${implementationAddress2}`
      );
      var [owner, alice] = await ethers.getSigners();
      await upgradeabletoken2.mint(alice.address, 1000000000n);
      var balanceAlice = await upgradeabletoken2.balanceOf(alice.address);
      console.log(balanceAlice);
    });
  });
});
