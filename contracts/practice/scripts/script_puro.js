const { ethers } = require("ethers");
require("dotenv").config();

/*
Ambiente Nodejs, sin el contexto de hardhat
Usa solo la libreria ethers.js

Correr el script con nodejs: 
node script_puro.js
*/

var abi = require("../../../artifacts/contracts/practice/contracts/PeruToken.sol/PeruToken.json").abi;
var bytecode = require("../../../artifacts/contracts/practice/contracts/PeruToken.sol/PeruToken.json").bytecode;

//var MINTER_ROLE = ethers.solidityPackedKeccak256(["string"], ["MINTER_ROLE"]);
var MINTER_ROLE = ethers.keccak256(ethers.toUtf8Bytes("MINTER_ROLE"));

async function main() {

    var provider = new ethers.JsonRpcProvider(process.env.GOERLI_TESNET_URL); // var goerliProvider
    var wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
    var wallet2 = new ethers.Wallet(process.env.OTHER_ACCOUNT_PRIVATE_KEY, provider);
    var account = wallet.address;
    var otherAccount = wallet2.address;

    console.log("wallet balance 1:", await provider.getBalance(wallet));

    // DEPLOYAR EL CONTRATO EN GOERLI

    // 1ra forma
    var factory = new ethers.ContractFactory(abi, bytecode, wallet);
    var contract = await factory.deploy('Peru Token', 'PETKN');
    var tx = await contract.waitForDeployment();

    // opcional esperar confirmaciones
    // await tx.deploymentTransaction().wait(5);

    console.log("wallet balance 2:", await provider.getBalance(account));

    var peruTokenAddress = await contract.getAddress();
    console.log("PeruToken Address:", peruTokenAddress);


    // UNA VEZ DEPLOYADO EL CONTRATO, OBTENER UNA INSTANCIA DEL CONTRATO


    // 1ra forma
    var contract = new ethers.Contract(peruTokenAddress, abi, wallet);

    // 2da forma
    // No es la mejor forma pues: A ContractFactory is used to deploy a Contract to the blockchain.
    var factory = new ethers.ContractFactory(abi, bytecode, wallet);
    var contract2 = factory.attach(peruTokenAddress);

    console.log("wallet balance 3:", await provider.getBalance(account));

    console.log("MINTER_ROLE:", MINTER_ROLE);

    tx = await contract.grantRole(MINTER_ROLE, otherAccount);
    await tx.wait();

    console.log("wallet balance 4:", await provider.getBalance(account));

    tx = await contract.connect(wallet2).mint(otherAccount, ethers.parseEther("10")); // BigInt(10*10**18)
    await tx.wait();

    console.log("wallet balance 5:", await provider.getBalance(account));


    console.log('instanciando el contrato...');

    var _abi = [
        "function nonces(address owner) public view returns (uint256)",
		"function name() public view returns(string memory)",
        "function grantRole(bytes32 role, address account) public"
	];

    //solo para llamar a metodos de lectura, se tendria que usar connect(wallet) en caso se quiera llamar a metodos de escritura
    var contract = new ethers.Contract(peruTokenAddress, _abi, provider); // donde provider = JsonRpcProvider

    // llamadas de solo lectura

    var name = await contract.name();
    console.log("name:", name);

    var nonce = await contract.nonces(await wallet.getAddress());
    console.log("nonces:", nonce);

    // llamada de escritura

    // funciona pues se usa connect(wallet)
    tx = await contract.connect(wallet).grantRole(MINTER_ROLE, otherAccount);
    await tx.wait();


    console.log('por fallar...');

    // aca falla pues no se usa connect(wallet)
    tx = await contract.grantRole(MINTER_ROLE, otherAccount);
    await tx.wait();

}

main();