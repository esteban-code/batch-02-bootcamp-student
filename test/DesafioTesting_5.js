var { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
var { expect } = require("chai");
var { ethers } = require("hardhat");

describe("Ejercicio Interfaz Simple Token", function () {
  async function deployFixture() {
    const [owner, alice, bob, carl] = await ethers.getSigners();

    const TokenTruco = await ethers.getContractFactory("TokenTruco");
    const tokenTruco = await TokenTruco.deploy();

    const Attacker = await ethers.getContractFactory("Attacker");
    const attacker = await Attacker.deploy(await tokenTruco.getAddress());

    return { tokenTruco, attacker, owner, alice, bob, carl };
  }

  describe("Ataque", function () {
    it("Owner tiene balance 0", async function () {
      const { tokenTruco, attacker, alice } = await loadFixture(deployFixture);
      await attacker.connect(alice).ejecutarAtaque();

      expect(await tokenTruco.balances(await tokenTruco.owner())).to.equal(0);
    });

    it("Attacker tiene un balance positivo", async function () {
      const { tokenTruco, attacker, alice } = await loadFixture(deployFixture);
      await attacker.connect(alice).ejecutarAtaque();

      expect(await tokenTruco.balances(alice.address)).to.be.gt(0);
    });
  });
});
