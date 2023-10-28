// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Mapping {
    //          llave   => valor
    // tabla: billetera => edades
    // Mapping:
    // - ya está inicializado todos su valores posibles
    // - Puedo consultar cualquier address y recibiré su valore por defecto
    // - No son iterables: no hay manera de saber qué llaves ya han sido usadas
    // - Por definción, todas las llaves son únicas.
    // - No podemos conocer la "longitud" de un mappin
    // - El mapping solo se puede definir dentro del area de Storage (memoria permanente)
    // - No puedo definir un mapping dentro de un método
    // - Si uso public, creo un getter automático:
    //          -> mapping(address => uint256) public listaAddressAEdad;
    // - No se puede obtener la llave a partir de un valor
    // - El valor puede ser repetido múltiple veces en diferentes filas
    // - Mientras que la llave es único (UUID)
    // - El mapping siempre se pasa como referencia
    // - No hay manera de pasar un mapping como valor porque ello implicaría crear una copia del mapping
    // - El tamaño del mapping depende del tipo de dato que se está usando
    mapping(address => uint256) listaAddressAEdad;
    address[] llavesDeLaLista; // address[]: crea un array cuyos elementos son del tipo address

    // Getter (del mapping) (asumiendo que no tengo public en el mapping
    // Leyendo una fila de mi table de lista de addresses
    function leerEdad(address account) public view returns (uint256) {
        return listaAddressAEdad[account]; // retorna edad
    }

    // Setter (del mapping)
    function actualizarLista(address account, uint256 edad) public {
        listaAddressAEdad[account] = edad;
        llavesDeLaLista.push(account);
    }

    // Tamaño del mapping
    // Tiene dos posible valores
    //  ---------------------------------------
    //          key         |           valores
    //          true        |               X1
    //          false       |               X2
    mapping(bool => uint256) booleanoAEntero;

    // Tiene 2ˆ256 posibles valores
    mapping(uint256 => uint256) enteroAEntero;

    // Tipos de dato para una llave (columna de la izquierda):
    // - todos menos un struct, mapping y un array

    // Tipos de dato para el valor  (columna de la derecha)
    // - todos

    // Delete (devolverlo a su valor default)
    function limpiarFilaEnTable(address account) public {
        delete listaAddressAEdad[account];
    }
}
