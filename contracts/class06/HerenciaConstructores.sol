// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Humano {
    string saludoHumano; // internal
    uint256 anioHumano; // internal

    constructor(string memory _saludoHumano, uint256 _anioHumano) {
        saludoHumano = _saludoHumano;
        anioHumano = _anioHumano;
    }
}

// Caso 1: directamente en la lista de Herencia
// Los valores tienes que saberlos a priori
contract Hombre1 is Humano("Hola, soy Humano", 46) {
    function getSaludoHumano() public view returns (string memory) {
        return saludoHumano;
    }
}

// Caso 2: como si fuera un modifier
// Los valores pueden inyectados cuando el hijo es publicado
// Los parámetros del constructor pueden ser pasados al constructor del papá (dinamicamente)
contract Hombre2 is Humano {
    constructor(string memory _saludo, uint256 _year) Humano(_saludo, _year) {}
}
