// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Humano {
    function saludoHumano() public pure returns (string memory) {
        return "Hola soy humano";
    }
}

// super
// Hace un busqueda del meotodo en todos los papas de derecha a izquierda
contract Hombre is Humano {
    function saludoHombre() public pure returns (string memory) {
        return "hola soy Hombre";
    }

    function bienvenidaDeHumano() public pure returns (string memory) {
        return super.saludoHumano();
    }

    function bienvenidaDeHumano2() public pure returns (string memory) {
        return Humano.saludoHumano();
    }
}

contract Marcos is Humano, Hombre {
    function saludoMarcos() public pure returns (string memory) {
        return "hola soy Marcos";
    }
}
