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

contract Hombre {
    function saludar() public pure virtual returns (string memory) {
        return "Hola, soy Hombre";
    }
}

contract Marcos is Hombre, Humano {
    // dentro del 'override' no existe un orden en específico
    function saludar()
        public
        pure
        override(Hombre, Humano)
        returns (string memory)
    {
        return "hola soy Marcos";
    }

    // Super empieza a buscar los métodos de derecha a izquierda
    // Si Humano está más a la derecha, super buscará allí primero
    // Si Hombre está más a la derecha, super buscará allí primero
    function saludoPapaConSuper() public pure returns (string memory) {
        return super.saludar();
    }
}

contract A {
    function a() public {}

    function b() public {}

    function c() public {}

    function d() public {}
}

contract Intermedio is A {}
