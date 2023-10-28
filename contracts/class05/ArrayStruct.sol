// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract ArrayStruct {
    struct DNI {
        uint256 numero;
        string nombre;
        string apellido;
    }

    // T[]: array dinamico
    DNI[] public listaDeVotantes;

    function guardarDniEnArray() public {
        listaDeVotantes.push(DNI(12341234, "Lee", "M."));
        listaDeVotantes.push(
            DNI({numero: 12341234, nombre: "Lee", apellido: "M."})
        );

        // cuando lo tengo en memoria lo puedo modificar en el camino
        DNI memory _dni = DNI(12341234, "Lee", "M.");
        _dni.numero = 546745678;
        _dni.apellido = "Marreros";
        listaDeVotantes.push(_dni); // guardando lo que esta en memory lo pasamos a storage
    }
}

contract ArrayStructMapping {
    struct Profesor {
        string nombre;
        uint256 edad;
        string[] materiasADictar;
    }
    //      address             |           Profesor
    //    _profesorAddress                  _profesor
    mapping(address => Profesor) public profesores;

    // Cuando pasas un string, bytes, array en parametro lo pasas en memory o calldata
    function guardarProfesorMemory(address _profesorAddress, uint256 n) public {
        // Cuando lo creas en memory, el array tiene que ser acotado por adelantado
        Profesor memory profesor = Profesor({
            nombre: "Luis",
            edad: 33,
            materiasADictar: new string[](n)
        });
        profesores[_profesorAddress] = profesor;
    }

    function guardarProfesorReferencia(address _profesorAddress) public {
        // Cuando lo pasas por referencia (storage), puedes hacer uso del array dinamico sin limite
        Profesor storage _profesor = profesores[_profesorAddress]; // columna de la derecha (valor)
        _profesor.nombre = "Luis";
        _profesor.edad = 33;
        _profesor.materiasADictar.push("Algebra");
        _profesor.materiasADictar.push("Matematica");
        _profesor.materiasADictar.push("Trigo");
        // ... sucesivamente
    }
}
