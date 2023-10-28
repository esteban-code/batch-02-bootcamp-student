var { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
var { expect } = require("chai");
var { ethers } = require("hardhat");

describe("Mappings: simple, double, triple", function () {
  async function deployFixture() {
    const [owner, alice] = await ethers.getSigners();

    const MappingSol = await ethers.getContractFactory("Desafio_1");
    const mappingSol = await MappingSol.deploy();

    return { mappingSol, owner, alice };
  }

  describe("Mapping Simple", function () {
    it("Guarda activos", async function () {
      const { mappingSol, owner, alice } = await loadFixture(deployFixture);
      await mappingSol.guardarActivoSimple(owner.address, 1);
      expect(await mappingSol.activosSimple(owner.address)).to.equal(1);
    });

    it("Valida activo", async function () {
      const { mappingSol, owner, alice } = await loadFixture(deployFixture);

      await expect(
        mappingSol.guardarActivoSimple(ethers.ZeroAddress, 1)
      ).to.be.revertedWith("El address no puede ser 0x00");
    });
  });

  describe("Mapping Double", function () {
    it("Guarda activos", async function () {
      const { mappingSol, owner, alice } = await loadFixture(deployFixture);
      await mappingSol.guardarActivoDoble(owner.address, 1, 1);
      expect(await mappingSol.activosDouble(owner.address, 1)).to.equal(1);
    });

    it("Valida activo", async function () {
      const { mappingSol, owner, alice } = await loadFixture(deployFixture);

      await expect(
        mappingSol.guardarActivoDoble(owner.address, 1000000, 1)
      ).to.be.revertedWith("Codigo de activo invalido");

      await expect(
        mappingSol.guardarActivoDoble(ethers.ZeroAddress, 1, 1)
      ).to.be.revertedWith("El address no puede ser 0x00");
    });
  });

  describe("Mapping Triple", function () {
    it("Guarda activos", async function () {
      const { mappingSol, owner, alice } = await loadFixture(deployFixture);
      await mappingSol.guardarActivoTriple(1, owner.address, 1, 1);
      expect(await mappingSol.activosTriple(1, owner.address, 1)).to.equal(1);
    });

    it("Valida activo", async function () {
      const { mappingSol, owner, alice } = await loadFixture(deployFixture);

      await expect(
        mappingSol.guardarActivoTriple(1, ethers.ZeroAddress, 1, 1)
      ).to.be.revertedWith("El address no puede ser 0x00");

      await expect(
        mappingSol.guardarActivoTriple(1, owner.address, 1000000, 1)
      ).to.be.revertedWith("Codigo de activo invalido");

      await expect(mappingSol.guardarActivoTriple(1000000, owner.address, 1, 1))
        .to.revertedWithCustomError(mappingSol, "CiudadInvalidaError")
        .withArgs(1000000);
    });
  });
});
