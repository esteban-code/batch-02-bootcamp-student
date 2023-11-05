const { ethers } = require("hardhat");
//const hre = require("hardhat");

/*
Ambiente Nodejs, en el contexto de hardhat

Correr el script con npx: 
npx hardhat --network goerli run script_hardhat.js
*/

var abi = require("../../../artifacts/contracts/practice/contracts/PeruToken.sol/PeruToken.json").abi;
var bytecode = require("../../../artifacts/contracts/practice/contracts/PeruToken.sol/PeruToken.json").bytecode;

//var MINTER_ROLE = ethers.solidityPackedKeccak256(["string"], ["MINTER_ROLE"]);
var MINTER_ROLE = ethers.keccak256(ethers.toUtf8Bytes("MINTER_ROLE"));

async function main() {
    
    var provider = ethers.provider;
    var [signer, signer2] = await ethers.getSigners();//signer es el primer signer configurado en hardhat.config
    var account = signer.address;
    var otherAccount = signer2.address;

    console.log("wallet balance 1:", await provider.getBalance(signer));

    // DEPLOYAR EL CONTRATO EN LA RED INDICADA AL EJECUTAR NPX HARDHAT

    // 1ra forma
    var factory = new ethers.ContractFactory(abi, bytecode, signer);
    var contract = await factory.deploy('Peru Token', 'PETKN');
    var tx = await contract.waitForDeployment();

    // opcional esperar confirmaciones
    // await tx.deploymentTransaction().wait(5);

    console.log("wallet balance 2:", await provider.getBalance(account));

    var peruTokenAddress = await contract.getAddress();
    console.log("PeruToken Address:", peruTokenAddress);

    // 2da forma
    //Internamente deployContract lee el artifact y llama a: ethers.ContractFactory(...) y factory.deploy(...), asignando a ContractFactory el primer signer configurado en hardhat.config
    var contract = await ethers.deployContract("PeruToken", ['Peru Token', 'PETKN']);
    var tx = await contract.waitForDeployment();

    // opcional esperar confirmaciones
    // await tx.deploymentTransaction().wait(5);

    console.log("wallet balance 2b:", await provider.getBalance(account));

    var peruTokenAddress = await contract.getAddress();
    console.log("PeruToken Address:", peruTokenAddress);
    

    // UNA VEZ DEPLOYADO EL CONTRATO, OBTENER UNA INSTANCIA DEL CONTRATO


    // 1ra forma
    var contract = new ethers.Contract(peruTokenAddress, abi, signer);

    tx = await contract.grantRole(MINTER_ROLE, otherAccount);
    await tx.wait();

    // 2da forma
    // Internamente getContractFactory lee el artifact y llama a ethers.ContractFactory(...) asignando a ContractFactory el primer signer configurado en hardhat.config
    // No es la mejor forma pues: A ContractFactory is used to deploy a Contract to the blockchain.
    var factory = await ethers.getContractFactory("PeruToken");
    var contract2 = factory.attach(peruTokenAddress);

    tx = await contract2.grantRole(MINTER_ROLE, otherAccount);
    await tx.wait();

    // 3ra forma
    // Internamente getContractAt lee el artifact y llama a ethers.Contract(...), asignando a Contract el primer signer configurado en hardhat.config
    var contract = await ethers.getContractAt('PeruToken', peruTokenAddress);

    console.log("wallet balance 3:", await provider.getBalance(account));

    console.log("MINTER_ROLE:", MINTER_ROLE);

    tx = await contract.grantRole(MINTER_ROLE, otherAccount);
    await tx.wait();

    console.log("wallet balance 4:", await provider.getBalance(account));

    tx = await contract.connect(signer2).mint(otherAccount, ethers.parseEther("10")); // BigInt(10*10**18)
    await tx.wait();

    console.log("wallet balance 5:", await provider.getBalance(account));


    console.log('instanciando el contrato...');

    var _abi = [
        "function nonces(address owner) public view returns (uint256)",
		"function name() public view returns(string memory)",
        "function grantRole(bytes32 role, address account) public"
	];

    //solo para llamar a metodos de lectura, se tendria que usar connect(signer) en caso se quiera llamar a metodos de escritura
    var contract = new ethers.Contract(peruTokenAddress, _abi, provider); // donde provider = ethers.provider

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

}

main();