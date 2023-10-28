// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract ArrayEnMemory {
    // Arrays en memory (dentro de los métodos)
    // - dentro de los métodos solo se pueden crear arrays de tamaño fijo

    // pure
    // - cuando no lees una variable del contrato
    // - cuando no se hace ningún cambio de estado en el método ( no es setter)

    function crearArrayEnMemoryDinamico(
        uint256 n
    ) public pure returns (uint256[] memory) {
        uint256[] memory arrayEnMemory = new uint256[](n); // Es de tamaño fijo
        // Operar este array como si fuera de tamaño fijo
        // No hay pop ni push
        arrayEnMemory[0] = 1;
        arrayEnMemory[1] = 2;
        arrayEnMemory[2] = 3;

        return arrayEnMemory;
    }

    function crearArrayEnMemoryFijo() public pure returns (uint256[10] memory) {
        uint256[10] memory arrayEnMemory; // No es necesario  = new uint256[](n)
        for (uint256 i; i < arrayEnMemory.length; i++) {
            arrayEnMemory[i] = i;
        }
        return arrayEnMemory;
    }
}
