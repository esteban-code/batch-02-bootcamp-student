// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Humano {
    string saludoHumano;
    uint256 anioHumano;

    constructor(string memory _saludoHumano, uint256 _anioHumano) {
        saludoHumano = _saludoHumano;
        anioHumano = _anioHumano;
    }
}

contract Hombre {
    uint256 height;

    constructor(uint256 _height) {
        height = _height;
    }
}

// Hombre y Humano no tienen ninguna relacion (el orden de herencia no importa)
// (importa sí para la palabra super)
// contract Programador is Hombre, Humano {
contract Programador is Humano, Hombre {
    constructor(
        string memory _saludo,
        uint256 _anio,
        uint256 _height,
        uint256 _dni,
        uint256 _dni2
    ) Hombre(_height) Humano(_saludo, _anio) {}
}
