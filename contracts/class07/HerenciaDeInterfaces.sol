// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IEleccion {
    function votar(uint256 candidato) external;

    function consultarConteo() external view;
}

interface IVotante is IEleccion {
    function consultarVoto() external returns (uint256);
}

// Segundo caso de uso - Camisa de fuerza
// Sirve para que el contrato se autoaplique un conjunto de reglas
// Sirve para estandarizar un contrato inteligente (el contrato se somete a implementar ciertos metodos)
contract Persona is IVotante {
    function votar(uint256 candidato) external {}

    function consultarConteo() external view {}

    function consultarVoto() external returns (uint256) {}
}

contract Persona2 {
    // IEleccion eleccion = IEleccion(0x0000);
}
