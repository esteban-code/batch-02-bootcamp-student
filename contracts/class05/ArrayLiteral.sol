// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract ArrayLiterals {
    // uint256: unsigned integer = entero sin signo [0, 2^256 -1]
    uint256[] public arrayDinamico = [1, 2, 3, 4, 5]; // puedo manipularlo con push y pop
    uint256[5] public arrayFijo = [1, 2, 3, 4, 5]; // no hay ni push ni pop. solo jugar con el index

    // int8: entero con signo: [-2ˆ7, 2^7 -1] porque usa un bit para el signo
    // Cuando se trabaja con arrays literal, Solidity toma el primer valor del array como guia
    // Eso quiere decir que va a castear todo el array fijandose en el primer elemnto del array
    // [1, 123, 5555555, 100000000] => Como 1er elemnto (1) es un uint8, todos los demas tambien son uint8
    // 1 es uint8: sí
    // 123 es uint8: sí
    // 55555555 es unint8: no
    // 100000000 es unint8: no
    // uint256[] array = [1, 44444];

    // [1, -1]: solidity piensa que todos los elementos son uint8 porque ve al uno
    // solucion [int8(1), -1]
    int8[2] public arrayNumerosNegativos = [int8(1), -1];

    function crearArrayLiteralEnMemory() public pure {
        // uint256[4] memory arrayLiteralMemory = [1,2,3,444444]; piensa que todo es uint8
        uint256[4] memory arrayLiteralMemory = [uint256(1), 2, 3, 444444];
    }
}
