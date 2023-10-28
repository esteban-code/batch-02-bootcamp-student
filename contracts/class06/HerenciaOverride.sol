// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Herencia de métodos
// Sobreescribir
// - Marcar el método (en el papá) que yo quiero sobreescribir con 'virtual'
// - Al sobreescibirlo (en el hijo) lo marco con override

// Function override: mismo nombre diferentes parametros (en el metodo)

contract Humano {
    function saludar() public pure virtual returns (string memory) {
        return "Hola, soy Humano";
    }
}

contract Hombre is Humano {
    function saludar() public pure override returns (string memory) {
        return "Hola, soy Hombre";
    }

    function saludarDeHumano() public pure returns (string memory) {
        // return Humano.saludar();
        return super.saludar();
    }
}
