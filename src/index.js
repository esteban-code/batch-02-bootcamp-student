import { /**/Contract,/**/ ethers } from "ethers";

var provider, account, signer, subastaContract;

// Importar ABI
var subastaAbi =
  require("../artifacts/contracts/class15/EnglishAuction.sol/EnglishAuctionDec.json").abi;

async function setUpMetamask() {
  var bttn = document.getElementById("connect");

  var walletIdEl = document.getElementById("walletId");

  bttn.addEventListener("click", async function () {
    if (window.ethereum) {
      // valida que exista la extension de metamask conectada
      [account] = await ethereum.request({
        method: "eth_requestAccounts",
      });
      console.log("Billetera metamask", account);
      walletIdEl.innerHTML = account;

      provider = new ethers.BrowserProvider(window.ethereum);
      signer = await provider.getSigner(account);
    }
  });
}

function setUpListeners() {
  // function creaSubasta(uint256 _startTime, uint256 _endTime)
  // 1. Obtén el botón createAuctionBttn
  var createAuctionBttn = document.getElementById("createAuctionButton");
  // 2. Añade click listener a createAuctionBttn
  createAuctionBttn.addEventListener("click", async function () {
    // 3. Captura el valor de start time
    var inputStartTime = document.getElementById("startTimeId");
    // 4. Captura el valor de end time
    var inputEndTime = document.getElementById("endTimeId");

    // En un try catch
    try {
      // 5.
      // Ejecuta el contrato subastaContract
      // Conectalo con el signer
      // Ejecuta el metodo con sus argumentos
      var tx = await subastaContract
        .connect(signer)
        .creaSubasta(inputStartTime.value, inputEndTime.value, { value: 1 });
      // Para enviar Ether usar: {value: etherAmount}
      // Esperar que se valide un bloque con await tx.wait();
      var res = await tx.wait();
      // De la respuesta sacar el transaction Hash
      console.log(res.hash);
      // await subastaContract.creaSubasta
    } catch (error) {
      // 6.
      // Si la transacción falla, imprimir 'reason': error.reason
      console.log(error.reason);
    }

    // Limpia los valores
    inputStartTime.innerHTML = "";
    inputEndTime.innerHTML = "";
  });

  // function proponerOferta(bytes32 _auctionId)
  var proposeOfferBttn = document.getElementById("proposeOfferBttn");
  proposeOfferBttn.addEventListener("click", async function () {
    var auctionId = document.getElementById("offerAuctionIdInput");
    var offerAmount = document.getElementById("offerAmountInput");

    try {
      var tx = await subastaContract
        .connect(signer)
        .proponerOferta(auctionId.value, {
          value: offerAmount.value,
        });
      var response = await tx.wait();
      var transactionHash = response.hash;
      console.log("Tx Hash", transactionHash);
    } catch (error) {
      console.log(error.reason);
    }

    auctionId.innerHTML = "";
  });

  // function finalizarSubasta(bytes32 _auctionId)
  var endAuctionBttn = document.getElementById("endAuctionBttn");
  endAuctionBttn.addEventListener("click", async function () {
    var auctionId = document.getElementById("endAuctionIdInput");
    var endAuctionError = document.getElementById("endAuctionError");
    endAuctionError.innerHTML = "";
    try {
      var tx = await subastaContract
        .connect(signer)
        .finalizarSubasta(auctionId.value);
      var response = await tx.wait();
      var transactionHash = response.hash;
      console.log("Tx Hash", transactionHash);
    } catch (error) {
      console.log(error.reason);
      endAuctionError.innerHTML = error.reason;
    }
  });

  // function recuperarOferta(bytes32 _auctionId)
  var withdrawOfferBttn = document.getElementById("withdrawOfferBttn");
  withdrawOfferBttn.addEventListener("click", async function () {
    var auctionId = document.getElementById("withdrawOfferInput");
    try {
      var tx = await subastaContract
        .connect(signer)
        .recuperarOferta(auctionId.value);
      var response = await tx.wait();
      var transactionHash = response.hash;
      console.log("Tx Hash", transactionHash);
    } catch (error) {
      console.log(error.reason);
    }
  });

  // function verSubastasActivas()
  var activeAuctionBttn = document.getElementById("activeAuctionBttn");
  activeAuctionBttn.addEventListener("click", async function () {
    var list = document.getElementById("liveAuctionsList");
    list.innerHTML = "";

    var res = await subastaContract.verSubastasActivas();//donde la funcion retorna bytes32[]
    console.log(res);
    res.forEach((subastaActiva, ix) => {
      var child = document.createElement("li");
      child.innerText = `Subasta ${ix + 1}: ${subastaActiva}`;
      list.appendChild(child);
    });
  });

  // public auctions:
  var consultAuctionBttn = document.getElementById("consultAuctionBttn");
  consultAuctionBttn.addEventListener("click", async function () {
  // el mapping auctions: mapping(bytes32 => Auction) public auctions;
  // Auction es un struct, y en js lo toma como un array
    var consultAuctionInput = document.getElementById("consultAuctionInput");//capturo este bytes32 de la anterior llamada a verSubastasActivas()
    var auctionInfoArr = await subastaContract.auctions(
      consultAuctionInput.value
    );

    var labels = ["startTime", "endTime", "highestBidder", "highestBid"];
    var auctionInfoId = document.getElementById("auctionInfoId");

    auctionInfoArr.forEach((info, ix) => {
      var child = document.createElement("li");
      child.innerHTML = `${labels[ix]}: ${info}`;
      auctionInfoId.appendChild(child);
    });
  });
}

function setUpSmartContracts() {
  // Subasta Contract: Copiar de la red de Mumbai
  // 0xB7320bE0275c2bD6b8210712E67cc009999b8170
  var subastaAddress = "0xB7320bE0275c2bD6b8210712E67cc009999b8170";

  // Proveedor de metamask
  provider = new ethers.BrowserProvider(window.ethereum);

  // Usando Ethers
  // Contract = address + abi + provider
  subastaContract = new Contract(subastaAddress, subastaAbi, provider);//o new ethers.Contract(...) // import { ethers } from "ethers";
}

function setUpEvents() {
  // Escucha al evento SubastaCreada
  subastaContract.on("SubastaCreada", (auctionId, billeteraCreador) => {
    console.log("auctionId", auctionId);
    console.log("billeteraCreador", billeteraCreador);
  });

  // Escucha al evento OfertaPropuesta
  subastaContract.on("OfertaPropuesta", (bidder, bid) => {
    console.log("bidder", bidder);
    console.log("(bidder", bidder);
  });
}

async function setUp() {
  // 1. Inicializar Metamask para obtner signer
  await setUpMetamask();

  // 2. Inicializar los smart contracts
  setUpSmartContracts();

  // 3. Inicializar los listeners de los botones
  setUpListeners();

  // 4. Set up Events
  setUpEvents();
}

setUp()
  .then()
  .catch((e) => console.log(e));
