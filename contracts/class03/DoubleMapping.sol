// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract DoubleMapping {
    // | ------------- | -------- | ------ | ---------- | --------- |
    // |   address     | Historia | Lengua | Matematica | Geografia | <- string
    // | Juan (0x01)   | 20       | 20     | 20         | 20        |
    // | Maria (0x02)  | 20       | 20     | 20         | 20        | <- uint256
    // | Carlos (0x03) | 20       | 20     | 20         | 20        |
    // | Sara (0x04)   | 20       | 20     | 20         | 20        |

    // Juan
    // materias => notas
    // mapping(string => uint256) materiaYNotas;

    // Maria
    // materias => notas
    // mapping(string => uint256) materiaYNotas;

    // Carlos
    // materias => notas
    // mapping(string => uint256) materiaYNotas;

    //          key1                        key2                valor
    mapping(address alumno => mapping(string materia => uint256 nota)) notasPorAlumno;

    // setter
    // memory o calldata
    function guardarNotaParaAlumno(
        address alumno,
        string memory materia,
        uint256 nota
    ) public {
        notasPorAlumno[alumno][materia] = nota;
    }

    // getter
    function leerNotaDeUnaMateriaDelAlumno(
        address alumno,
        string memory materia
    ) public view returns (uint256 nota) {
        // return notasPorAlumno[alumno][materia]; // leyendo la nota en donde X y Y coinciden
        nota = notasPorAlumno[alumno][materia]; // ya no es necesario utilizar 'return'
    }

    // resetear un valor de la matriz
    function limpiarNotaDeUnAlumno(
        address alumno,
        string calldata materia
    ) public {
        delete notasPorAlumno[alumno][materia];
    }

    // Limpiar todas las materias de un alumno
    // notasPorAlumno[key1][key2] // devuelve el valor en esta coordenada X, Y
    function limpiarTodasMateriasDeUnAlumno(
        address alumno,
        uint256 nota
    ) public {
        // esto no es factible
        // los valores se eliminan uno por uno (x, y)
        // delete notasPorAlumno[alumno];
        // delete notasPorAlumno[alumno][nota];
    }
}
