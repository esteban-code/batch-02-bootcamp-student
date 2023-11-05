import { ethers } from "../../../node_modules/ethers/dist/ethers.js";
import peruTokenJson from "../../../artifacts/contracts/practice/contracts/PeruToken.sol/PeruToken.json" assert { type: "json" };

/*
javascript puro sin Nodejs, sin el contexto de hardhat
Usa solo la libreria ethers.js

start Live Server
http://127.0.0.1:5500/contracts/practice/frontend/index.html
*/

var abi = peruTokenJson.abi;
var bytecode = peruTokenJson.bytecode;

//debugger;
if(!window.ethereum){
    alert('No tiene la extension metamask instalado');
    throw new Error('No se tiene la extension metamask instalado');
}
//var account, otherAccount;
var [account, otherAccount] = await ethereum.request({ method: "eth_requestAccounts", });
var provider = new ethers.BrowserProvider(window.ethereum);
var signer = await provider.getSigner(account);
var signer2 = await provider.getSigner(otherAccount);

var peruTokenAddress = "";
// var peruTokenAddress = "0x8D4bd46086B88433c192E227fbd3685901B0929B";

// var MINTER_ROLE = ethers.solidityPackedKeccak256(["string"], ["MINTER_ROLE"]);
var MINTER_ROLE = ethers.keccak256(ethers.toUtf8Bytes("MINTER_ROLE"));

var txtContractAddress = document.getElementById("txtContractAddress");
var txtContractAddress2 = document.getElementById("txtContractAddress2");
var txtEtherBalance = document.getElementById("txtEtherBalance");
var txtPeruTokenBalance = document.getElementById("txtPeruTokenBalance");

var bttn = document.getElementById("deployBtn");
bttn.addEventListener("click", async function () {
    debugger;

    txtEtherBalance.value += "wallet balance 1: " + await provider.getBalance(signer) + "\n";

    // DEPLOYAR EL CONTRATO EN LA RED ACTIVA EN METAMASK

    var factory = new ethers.ContractFactory(abi, bytecode, signer);
    var contract = await factory.deploy('Peru Token', 'PETKN');
    var tx = await contract.waitForDeployment();

    // opcional esperar confirmaciones
    // await tx.deploymentTransaction().wait(5);

    txtEtherBalance.value += "wallet balance 2: " + await provider.getBalance(account) + "\n";

    peruTokenAddress = await contract.getAddress();
    txtContractAddress.value = peruTokenAddress;

    txtEtherBalance.value += "wallet balance 3: " + await provider.getBalance(account) + "\n";

    txtPeruTokenBalance.value += "wallet balance 1: " + await contract.balanceOf(account) + "\n";
});

var bttn = document.getElementById("callBtn");
bttn.addEventListener("click", async function () {
    debugger;

    txtEtherBalance.value += "wallet balance 1: " + await provider.getBalance(account) + "\n";

    // UNA VEZ DEPLOYADO EL CONTRATO, OBTENER UNA INSTANCIA DEL CONTRATO
    
    // 1ra forma
    var contract = new ethers.Contract(peruTokenAddress, abi, signer);

    // 2da forma 
    // No es la mejor forma pues: A ContractFactory is used to deploy a Contract to the blockchain.
    var factory = new ethers.ContractFactory(abi, bytecode, signer);
    var contract2 = factory.attach(peruTokenAddress);

    peruTokenAddress = await contract.getAddress();
    txtContractAddress2.value = peruTokenAddress;

    txtEtherBalance.value += "wallet balance 2: " + await provider.getBalance(account) + "\n";

    var tx = await contract.grantRole(MINTER_ROLE, otherAccount);
    await tx.wait();

    txtEtherBalance.value += "wallet balance 3: " + await provider.getBalance(account) + "\n";
    txtEtherBalance.value += "wallet2 balance 1: " + await provider.getBalance(otherAccount) + "\n";

    tx = await contract.connect(signer2).mint(otherAccount, ethers.parseEther("10"));
    await tx.wait();

    txtEtherBalance.value += "wallet balance 4: " + await provider.getBalance(account) + "\n";
    txtEtherBalance.value += "wallet2 balance 2: " + await provider.getBalance(otherAccount) + "\n";

    txtPeruTokenBalance.value += "wallet balance 2: " + await contract.balanceOf(account) + "\n";
    txtPeruTokenBalance.value += "wallet2 balance 1: " + await contract.balanceOf(otherAccount) + "\n";

    console.log('instanciando el contrato...');

    var _abi = [
        "function nonces(address owner) public view returns (uint256)",
		"function name() public view returns(string memory)",
        "function grantRole(bytes32 role, address account) public"
	];

    //solo para llamar a metodos de lectura, se tendria que usar connect(signer) en caso se quiera llamar a metodos de escritura
    var contract = new ethers.Contract(peruTokenAddress, _abi, provider); // donde provider = BrowserProvider

    // llamadas de solo lectura

    var name = await contract.name();
    console.log("name:", name);

    var nonce = await contract.nonces(await signer.getAddress());
    console.log("nonces:", nonce);

    // llamada de escritura

    // funciona pues se usa connect(signer)
    tx = await contract.connect(signer).grantRole(MINTER_ROLE, otherAccount);
    await tx.wait();


    console.log('por fallar...');

    // aca falla pues no se usa connect(signer)
    tx = await contract.grantRole(MINTER_ROLE, otherAccount);
    await tx.wait();

});
