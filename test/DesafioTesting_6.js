const { expect } = require("chai");
const { ethers } = require("hardhat");

const getRole = (role) => ethers.keccak256(ethers.toUtf8Bytes(role));

const MINTER_ROLE = getRole("MINTER_ROLE");
const BURNER_ROLE = getRole("BURNER_ROLE");

describe("MI PRIMER TOKEN TESTING", function () {
  var MiPrimerToken, AirdropOne;
  var miPrimerToken, airdropOne;
  var owner, alice, bob, carl, deysi, estefan;

  before(async () => {
    [owner, alice, bob, carl, deysi, estefan] = await ethers.getSigners();
  });

  describe("Set Up", () => {
    it("Publicar los contratos", async () => {
      var name = "Mi Primer Token";
      var symbol = "MPRTKN";

      // publicar MiPrimerToken
      MiPrimerToken = await hre.ethers.getContractFactory("MiPrimerToken");
      miPrimerToken = await MiPrimerToken.deploy(name, symbol);

      // publicar AirdropOne
      AirdropOne = await hre.ethers.getContractFactory("AirdropOne");
      airdropOne = await AirdropOne.deploy(await miPrimerToken.getAddress());

      // Set Up
      await airdropOne.setTokenAddress(await miPrimerToken.getAddress());

      // Set up Roles Token => Airdrop
      await miPrimerToken.grantRole(MINTER_ROLE, await airdropOne.getAddress());
      await miPrimerToken.grantRole(BURNER_ROLE, await airdropOne.getAddress());
    });
  });

  describe("MiPrimerToken", () => {
    it("mint protegido por MITNER_ROLE", async () => {
      const mint = miPrimerToken.connect(alice).mint;
      await expect(
        mint(alice.address, ethers.parseEther("1000"))
      ).to.revertedWith(
        `AccessControl: account ${alice.address.toLowerCase()} is missing role ${MINTER_ROLE}`
      );
    });

    it("burn protegido por BURNER_ROLE", async () => {
      const burn = miPrimerToken.connect(alice)["burn(address,uint256)"];
      await expect(
        burn(bob.address, ethers.parseEther("1000"))
      ).to.revertedWith(
        `AccessControl: account ${alice.address.toLowerCase()} is missing role ${BURNER_ROLE}`
      );
    });
  });

  describe("AidropOne", () => {
    it("Address correcto del token MiPrimerToken", async () => {
      var tokenAdd = await airdropOne.miPrimerTokenAdd();
      expect(tokenAdd).to.be.equal(await miPrimerToken.getAddress());
    });

    describe("Participa en Aidrop", () => {
      it("Participante debe estar en lista blanca", async () => {
        // bob => no está en lista blanca
        await expect(
          airdropOne.connect(bob).participateInAirdrop()
        ).to.revertedWith("No esta en lista blanca");

        // agreguemos a bob a la lista blanca
        await airdropOne.connect(owner).addToWhiteList(bob.address);

        // bob puede participar
        await airdropOne.connect(bob).participateInAirdrop();
      });

      it("Participante ya participó", async () => {
        await expect(
          airdropOne.connect(bob).participateInAirdrop()
        ).to.revertedWith("Ya ha participado");
      });

      it("Participante recibió tokens", async () => {
        var balBobMiPrimerTkn = await miPrimerToken.balanceOf(bob.address);
        // balBobMiPrimerTkn >= 1 && balBobMiPrimerTkn <= 1000
        // balBobMiPrimerTkn es un big number que tiene propiedades
        // BigNumber.gte: mayor e igual
        // BigNumber.lte: menor e igual
        // console.log(ethers.utils.formatEther(balBobMiPrimerTkn));
        console.log();
        expect(
          balBobMiPrimerTkn >= ethers.parseEther("1") &&
            balBobMiPrimerTkn <= ethers.parseEther("1000")
        ).to.be.true;
      });
    });

    describe("Quema de tokens", () => {
      it("Usuario no ha participado", async () => {
        // carl no ha participado
        await expect(
          airdropOne.connect(carl).quemarMisTokensParaParticipar()
        ).to.revertedWith("Usted aun no ha participado");
      });

      it("Usuario no tiene balance", async () => {
        // carl se añade a la lista blanca
        await airdropOne.addToWhiteList(carl.address);
        // carl solicita tokens - ha participado
        await airdropOne.connect(carl).participateInAirdrop();
        // disminuye su balance por debajo de lo requerido
        var balCarl = await miPrimerToken.balanceOf(carl.address);
        await miPrimerToken
          .connect(carl)
          .transfer(alice.address, balCarl - ethers.parseEther("5"));

        await expect(
          airdropOne.connect(carl).quemarMisTokensParaParticipar()
        ).to.revertedWith("No tiene suficientes tokens para quemar");
      });

      it("Tokens quemados correctamente", async () => {
        // tokens a quemar
        const tokensAQuemar = ethers.parseEther("10");
        // alice se añade a la lista blanca
        await airdropOne.addToWhiteList(alice.address);
        // alice solicita tokens - ha participado
        await airdropOne.connect(alice).participateInAirdrop();
        // balance antes de quemar
        var balPrev = await miPrimerToken.balanceOf(alice.address);
        // alice quema sus tokens
        await airdropOne.connect(alice).quemarMisTokensParaParticipar();
        // balance después de quemar
        var balAfter = await miPrimerToken.balanceOf(alice.address);
        expect(balPrev - balAfter).to.be.equal(tokensAQuemar);
      });

      it("Habilitado de participar", async () => {
        const puedeParticipar = await airdropOne.haSolicitado(alice.address);
        expect(puedeParticipar).to.be.false;
      });
    });

    it("Lista blanca - añadido correctamente", async () => {
      // antes de participar
      var enLista = await airdropOne.whiteList(deysi.address);
      expect(enLista).to.be.false;

      // se añade a la lista blanca
      await airdropOne.addToWhiteList(deysi.address);

      // después de participar
      var enLista = await airdropOne.whiteList(deysi.address);
      expect(enLista).to.be.true;
    });

    it("Lista blanca - removido correctamente", async () => {
      // se añade a la lista blanca
      await airdropOne.addToWhiteList(estefan.address);
      var enLista = await airdropOne.whiteList(estefan.address);
      expect(enLista).to.be.true;

      /// se le quita de la lista blanca
      await airdropOne.removeFromWhitelist(estefan.address);
      var enLista = await airdropOne.whiteList(estefan.address);
      expect(enLista).to.be.false;
    });
  });
});

/**
 * Escenarios para testing
 *
 * MiPrimerToken
 *
 * 1. validar que mint está protegido por el rol MINTER_ROLE
 * 2. validar que burn está protegido por el rol BURNER_ROLE
 *
 * AIrdropONE
 *
 * 1. Validar que el address del token sea el correcto
 *
 * 2. Participar en airdrop
 *  2.1 Validar que esté en lista blanca
 *  2.2 Validar que ya haya participado
 *  2.3 Validar que haya recibido una cantidad de tokens apropiada
 *
 * 3. Quemar tokens para participar
 *  3.1 Validar que ha participado
 *  3.2 Validar que tiene el balance suficiente para quemar
 *  3.3 Verificar que sus tokens fueron quemados
 *  3.4 Verificar que puede volver a participar
 *
 * 4. Añadir a lista blanca
 *  4.1 Verificar se añade correctamente a la lista blanca
 *
 * 5. Remover de lista blanca
 *  5.1 Verificar se remueve correctamente de la lista blanca
 */
