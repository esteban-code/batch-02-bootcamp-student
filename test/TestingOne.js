const { ethers } = require("hardhat");
const { expect } = require("chai");

// carga mis contratos a memori y limpialos
const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("Testeando Contratos Inteligentes", () => {
  // Guardar en memoria (durante testing) y limpiar
  async function loadTestingOne() {
    // consultar una lista de signers de prueba
    // estos signers se pueden convertir en msg.sender en el contrato
    var [owner, alice, bob, carl] = await ethers.getSigners();

    // creando una referencia del contrato inteligente
    var TestingOne = await ethers.getContractFactory("TestingOne");

    // "publicarlo" dentro del contexto testing
    var year = 2023;
    var month = 9;
    var etherBalance = 1000; // 1000 wei

    // testingOne es el contrato "publicado"
    var testingOne = await TestingOne.deploy(year, month, {
      value: etherBalance,
    });

    return { testingOne, owner, alice, bob, carl };
  }

  // npx hardhat test test/TestingOne.js
  describe("Publicación (evaluar valores de init)", () => {
    it("Se publicó sin errores y con valores correctos", async () => {
      // cargando los contratos
      var { testingOne } = await loadFixture(loadTestingOne);
      var year = 2023;
      var month = 9;
      // expect que algo sea igual a algo
      expect(await testingOne.year()).to.be.equal(year, "El año no coincide");
      expect(await testingOne.month()).to.be.equal(month, "El mes no coincide");
    });
  });

  describe("Verificando msg.sender", () => {
    it("Ejecutando el método 'setYearAndMonth'", async () => {
      // cargando los contratos
      var { testingOne, owner, alice, bob, carl } = await loadFixture(
        loadTestingOne
      );
      // expect que algo sea igual a algo
      var year = 2500;
      var month = 1000;

      // owner se convier en msg.sender dentro de setyearAndMonth
      await testingOne.connect(owner).setYearAndMonth(year, month);
      expect(await testingOne.year()).to.be.equal(year);
      expect(await testingOne.month()).to.be.equal(month);
      expect(await testingOne.caller()).to.be.equal(await owner.getAddress());

      // alice se convier en msg.sender dentro de setyearAndMonth
      year = 3000;
      month = 33;
      await testingOne.connect(alice).setYearAndMonth(year, month);
      expect(await testingOne.year()).to.be.equal(year);
      expect(await testingOne.month()).to.be.equal(month);
      expect(await testingOne.caller()).to.be.equal(await alice.getAddress());
    });
  });

  describe("Disparando evento", () => {
    it('Llamando a "fireEvents"', async () => {
      // cargando los contratos
      var { testingOne, owner, alice, bob, carl } = await loadFixture(
        loadTestingOne
      );

      // cuando no se especifica con connect(), se asume que lo llama el owner
      var tx = await testingOne.fireEvents(); // ¿Quien es msg.sender?
      await expect(tx).to.emit(testingOne, "Caller");

      await expect(tx)
        .to.emit(testingOne, "Caller")
        .withArgs(await owner.getAddress());

      await expect(tx)
        .to.emit(testingOne, "CallerAndState")
        .withArgs(await owner.getAddress(), 2023, 9);
    });
  });

  describe("Validación de inputs", () => {
    it('Testeando "validarInput"', async () => {
      // cargando los contratos
      var { testingOne, owner, alice, bob, carl } = await loadFixture(
        loadTestingOne
      );

      // no voy a validar. al hacerlo no me salta el require
      //   await testingOne.validarInput(4000); // > a 1000

      var wrongInput = 100;
      await expect(testingOne.validarInput(wrongInput)).to.be.reverted;

      await expect(testingOne.validarInput(wrongInput)).to.be.revertedWith(
        "Input Incorrecto"
      );
    });

    it('Testeando "validarInput2"', async () => {
      // cargando los contratos
      var { testingOne, owner, alice, bob, carl } = await loadFixture(
        loadTestingOne
      );

      var wrongInput = 100;
      await expect(
        testingOne.validarInput2(wrongInput)
      ).to.be.revertedWithCustomError(testingOne, "WrongInput");
    });

    it('Testeando "validarInput3"', async () => {
      // cargando los contratos
      var { testingOne, owner, alice, bob, carl } = await loadFixture(
        loadTestingOne
      );

      var wrongInput = 100;
      await expect(testingOne.validarInput3(wrongInput))
        .to.be.revertedWithCustomError(testingOne, "WrongInputWithArgs")
        .withArgs(wrongInput);
    });
  });
  describe("Testeando envío de Ether", () => {
    var testingOne = null,
      owner = null;

    beforeEach(async function () {
      // cargando los contratos
      var fixtures = await loadFixture(loadTestingOne);
      testingOne = fixtures.testingOne;
      owner = fixtures.owner;
    });

    it('Enviando Ether a través de "enviarEther"', async () => {
      // loadFixture: ya no es necesario
      // cuando utilizo testingOne asumo que ha sido inicializado recientemente
      var etherAmount = 1000; // 1000 wei
      // lo envia owner (implicitamente)
      var tx = await testingOne.enviarEther({ value: etherAmount });

      await expect(tx).to.changeEtherBalance(
        await owner.getAddress(),
        -etherAmount
      );

      await expect(tx).to.changeEtherBalance(
        await testingOne.getAddress(),
        etherAmount
      );

      await expect(tx).to.changeEtherBalances(
        [await owner.getAddress(), await testingOne.getAddress()],
        [-etherAmount, etherAmount]
      );
    });

    it('Reclamando Ether a travès de "reclamarEther"', async () => {
      var etherAmount = 1000;
      var tx = await testingOne.reclamarEther(etherAmount);
      await expect(tx).to.changeEtherBalances(
        [await owner.getAddress(), await testingOne.getAddress()],
        [etherAmount, -etherAmount]
      );
    });
  });

  describe("Testando transferencia de Tokens ERC20", () => {
    var testingOne = null,
      owner = null;

    beforeEach(async function () {
      // cargando los contratos
      var fixtures = await loadFixture(loadTestingOne);
      testingOne = fixtures.testingOne;
      owner = fixtures.owner;
    });

    it("Testeando tokens ERC20", async () => {
      var amount = 10000;
      var tx = await testingOne.mint(await owner.getAddress(), amount);
      await expect(tx).changeTokenBalance(
        testingOne,
        await owner.getAddress(),
        amount
      );
    });
  });
});
