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

contract Hombre is Humano {
    uint256 height;

    constructor(
        string memory _saludo,
        uint256 _anio,
        uint256 _height
    ) Humano(_saludo, _anio) {
        height = _height;
    }
}

contract Programdor is Hombre {
    constructor(
        string memory _saludo,
        uint256 _anio,
        uint256 _height
    ) Hombre(_saludo, _anio, _height) {}
}
