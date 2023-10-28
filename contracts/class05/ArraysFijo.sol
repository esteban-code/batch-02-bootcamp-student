// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract ArrayTamanoFijo {
    // Array de tamaño fijo
    // T[k] nombreArray;
    // T: tipo de dato
    // k: cantidad de elementos de ese arrat fijo
    // - No existe el push
    // - No existe el pop
    // - Para guardar info en el array sus índices
    // - indice >= 0 && indice < k
    // - Si elimino un elemento del array, éste no se encoge.
    //      Solo se resetea a su valor default

    // 5 enteros en un array
    uint256[5] lista5Enteros;

    // 10 booleans en un array
    bool[10] lista10Bools;

    // 100 strings en un array
    string[100] lisat100Strings;

    function guardarInfoEnArray() public {
        // lista5Enteros
        lista5Enteros[0] = 0;
        lista5Enteros[1] = 1;
        lista5Enteros[2] = 2;
        lista5Enteros[3] = 3;
        lista5Enteros[4] = 4;
        // lista5Enteros[5] = 5; // Out of bounds

        for (uint256 i; i < lista10Bools.length; i++) {
            lista10Bools[i] = true;
        }
    }

    function borrarInformacion(uint256 pos) public {
        delete lista5Enteros[pos];
    }
}
