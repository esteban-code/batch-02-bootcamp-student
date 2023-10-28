// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Constructor {
    // OOP
    // Se utiliza para inicializar variables
    // Se llama una sola vez y ejecuta cuando el contrato se publica
    // El constructor se convierte byte (parte del codigo de inicialización) y no se guarda en Blockchain
    // Sirve para inyectar información del mundo de afuera
    // Me sirve para capturar al address de la persona que está publicando el contrato inteligente
    // El constructor es completamente opcional (a nivel de bytecode se incluye un constructor vacio)
    // Versiones antigas
    // function Constructor() {}
    // Sintaxis
    uint256 age;
    address owner;
    mapping(address => bool) whitelist;

    event Published();

    constructor(uint256 _age) {
        age = _age;
        owner = msg.sender;
        whitelist[msg.sender] = true;

        sum();
        emit Published();
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "No es el owner");
        _;
    }

    function protegerMetodoPorOwner() public onlyOwner {}

    function sum() public {}
}
