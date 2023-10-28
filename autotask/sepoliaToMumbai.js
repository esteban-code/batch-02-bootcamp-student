const { ethers } = require("ethers");
const {
  DefenderRelaySigner,
  DefenderRelayProvider,
} = require("defender-relay-client/lib/ethers");

exports.handler = async function (data) {
  // Eventos que vienen del sentinel
  // Este evento viene de Sepolia cuando el usuario participa en Airdrop
  const payload = data.request.body.events;

  // Inicializa Proveedor: en este caso es OZP
  const provider = new DefenderRelayProvider(data);

  // Se crea el signer quien será el msg.sender en los smart contracts
  const signer = new DefenderRelaySigner(data, provider, { speed: "fast" });

  // Filtrando solo eventos
  var onlyEvents = payload[0].matchReasons.filter((e) => e.type === "event");
  if (onlyEvents.length === 0) return;

  // Filtrando solo MintInAnotherChain
  var event = onlyEvents.filter((ev) =>
    ev.signature.includes("MintInAnotherChain")
  );
  // Mismos params que en el evento
  var { account, tokens } = event[0].params;

  // Ejecutar 'mint' en Mumbai del contrato MiPrimerToken
  var miPrimerTokenAdd = "0x4A16D22ae3A53E30ef0519F845511A990B0300B8";
  var tokenAbi = ["function mint(address to, uint256 amount)"];
  var tokenContract = new ethers.Contract(miPrimerTokenAdd, tokenAbi, signer);
  var tx = await tokenContract.mint(account, tokens);
  var res = await tx.wait();
  return res;
};
