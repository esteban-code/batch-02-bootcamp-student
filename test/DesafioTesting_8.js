var { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
var { expect } = require("chai");
var { ethers } = require("hardhat");

describe("Mappings: simple, double, triple", function () {
  async function deployFixture() {
    const [owner, alice] = await ethers.getSigners();

    const Loteria = await ethers.getContractFactory("LoteriaConPassword");
    const loteria = await Loteria.deploy({ value: 1500 });

    const Attacker = await ethers.getContractFactory("AttackerLoteria");
    const attacker = await Attacker.deploy();

    return { loteria, attacker, owner, alice };
  }

  describe("Mapping Simple", function () {
    it("Guarda activos", async function () {
      const { loteria, attacker, owner, alice } = await loadFixture(
        deployFixture
      );
      var loteriaAddress = await loteria.getAddress();
      var attackerAddress = await attacker.getAddress();

      var balanceLoteria = await ethers.provider.getBalance(loteriaAddress);
      expect(balanceLoteria).to.equal(1500, "Balance incorrecto");

      await attacker.attack(await loteria.getAddress(), { value: 1500 });

      balanceLoteria = await ethers.provider.getBalance(loteriaAddress);
      expect(balanceLoteria).to.equal(
        0n,
        "Después del ataque el contrato Loteria no debería tener balance"
      );

      var balanceAttacker = await ethers.provider.getBalance(attackerAddress);
      expect(balanceAttacker).to.equal(
        3000,
        "El atacante debería tener todo el balance del contrato Loteria"
      );
    });
  });
});
