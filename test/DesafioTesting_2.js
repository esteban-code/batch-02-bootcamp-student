var {
  loadFixture,
  setBalance,
  impersonateAccount,
  time,
} = require("@nomicfoundation/hardhat-network-helpers");
var { expect } = require("chai");
var { ethers } = require("hardhat");

describe("Modifiers - protección y validación", function () {
  async function deployFixture() {
    const [owner, alice] = await ethers.getSigners();

    const EjercicioDos = await ethers.getContractFactory("Desafio_2");
    const ejercicioDos = await EjercicioDos.deploy();

    return { ejercicioDos, owner, alice };
  }

  it("Verifica acceso a método - admin", async function () {
    const { ejercicioDos } = await loadFixture(deployFixture);

    await expect(ejercicioDos.metodoAccesoProtegido()).to.be.revertedWith(
      "No eres el admin"
    );

    var admin = "0x08Fb288FcC281969A0BBE6773857F99360f2Ca06";
    await impersonateAccount(admin);
    await setBalance(admin, ethers.toBigInt("10000000000000000000"));
    var signerAdmin = await ethers.provider.getSigner(admin);
    await ejercicioDos.connect(signerAdmin).metodoAccesoProtegido();
  });

  it("Verifica lista blanca", async function () {
    const { ejercicioDos, alice } = await loadFixture(deployFixture);
    await expect(ejercicioDos.metodoPermisoProtegido()).to.be.revertedWith(
      "Fuera de la lista blanca"
    );

    var admin = "0x08Fb288FcC281969A0BBE6773857F99360f2Ca06";
    await impersonateAccount(admin);
    await setBalance(admin, ethers.toBigInt("10000000000000000000"));
    var signerAdmin = await ethers.provider.getSigner(admin);
    await ejercicioDos.connect(signerAdmin).incluirEnListaBlanca(alice.address);

    await ejercicioDos.connect(alice).metodoPermisoProtegido();
  });

  it("Verifica rango de tiempo", async function () {
    const { ejercicioDos } = await loadFixture(deployFixture);
    await ejercicioDos.metodoTiempoProtegido();

    await time.increase(30 * 24 * 60 * 60 + 1);
    await expect(ejercicioDos.metodoTiempoProtegido()).to.be.revertedWith(
      "Fuera de tiempo"
    );
  });

  it("Verifica si está pausado", async function () {
    const { ejercicioDos } = await loadFixture(deployFixture);
    await ejercicioDos.metodoPausaProtegido();

    var admin = "0x08Fb288FcC281969A0BBE6773857F99360f2Ca06";
    await impersonateAccount(admin);
    await setBalance(admin, ethers.toBigInt("10000000000000000000"));
    var signerAdmin = await ethers.provider.getSigner(admin);
    await ejercicioDos.connect(signerAdmin).cambiarPausa();

    await expect(ejercicioDos.metodoPausaProtegido()).to.be.revertedWith(
      "El metodo esta pausado"
    );
  });
});
