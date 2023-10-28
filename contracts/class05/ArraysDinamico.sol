// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract ArrayTamanoDinamico {
    // T[] nombreArray;
    // - Para guardar informacion utilizo push
    // - Para eliminar informacion utilizo pop
    // - No se pueden guardar diferentes tipos de dato en un array
    // - tiene la propiedad .length

    // array dinámico de enteros
    uint256[] listaEnteros;

    // array dinamico de strings
    string[] listaDeStrings;

    // array dinamico de bool
    bool[] listaDeBools;

    // array dinamico de address
    address[] listaDeAddress;

    function guardarInfoEnArrayDinamico() public {
        listaEnteros.push(123); // [123]
        listaEnteros.push(456); // [123, 456]
        listaEnteros.push(789); // [123, 456, 789]
    }

    function eliminarInfoDeArrayDinamico() public {
        // [123, 456, 789]
        listaEnteros.pop(); //  => [123, 456]
        listaEnteros.pop(); // => [123]
        listaEnteros.pop(); // => []
    }
}
