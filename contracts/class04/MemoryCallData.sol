// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract MemoryCalldataStorage {
    // Estas memorias están al nivel del contrato inteligente
    // storage
    // memory
    // calldata

    // Los tipos de datos dinámico (son complejos)
    // Le ayudas al compilador diciéndole qué tipo de memoria usar para procesar dichos datos
    // Cuando le pasas tipos de datos fijos (no dinámicos) son simples y el EVM sabe como manejarlos

    // memory
    // - memoria temporal (existe mietran se ejecuta el método)
    // - asigna un espacio de memoria para duplica la variable y la puedes modificar
    // - mas costoso porque se duplica y se prepara para ser modificado
    string nombre;

    function setName(string memory _nombre) public {
        nombre = _nombre;
        _nombre = string.concat(_nombre, "Marreros");
        _nombre = ""; // Si se puede settear
    }

    // calldata
    // - la variable se pasa como si fuera una CONSTANTE
    // - no se puede modificar
    // - se hace menos costoso usar calldata (vs memory)
    function setNameCalldata(string calldata _nombre) public {
        nombre = _nombre;
        // _nombre = string.concat(_nombre, "Marreros");
        // _nombre = ""; // no se puede setetr una variable calldata
    }
}
