// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Eventos {
    // | ------------- | -------- | ------ | ---------- | --------- |
    // |   address     | Historia | Lengua | Matematica | Geografia | <- string
    // | Juan (0x01)   | 20       | 20     | 20         | 20        |
    // | Maria (0x02)  | 20       | 20     | 20         | 20        | <- uint256
    // | Carlos (0x03) | 20       | 20     | 20         | 20        |
    // | Sara (0x04)   | 20       | 20     | 20         | 20        |

    mapping(address alumno => mapping(string materia => uint256 nota))
        public notasPorAlumno;

    // event NombreDelEvento();
    event NotaGuardada();

    // event NombreDelEvento(otros arguemtos como contexto);
    event NotaGuardada(address _alumno, string _materia, uint256 _nota);

    // eventox indexados: búsqueda más precisa
    // Contribuye a una búsqueda más enriquecida (fácil)
    event NotaGuardadaIndexados(
        address indexed _alumno,
        string indexed _materia,
        uint256 indexed _nota,
        uint256 _nota2
    );

    // Evento anónimo
    // Sí se guarda en el blockchain
    // No se registra en el ABI: no puedes escucharlos (suscribirte)
    event GuardarNotaFueraDeAbi(
        address indexed _alumno,
        string indexed _materia,
        uint256 indexed _nota
    ) anonymous;

    function guardarNotaParaAlumno(
        address alumno,
        string memory materia,
        uint256 nota
    ) public {
        require(nota >= 0 && nota <= 20, "Nota fuera de rango");
        require(alumno != address(0), "Address Zero");
        require(bytes(materia).length > 0, "Materia esta vacia");

        notasPorAlumno[alumno][materia] = nota;
        emit NotaGuardada();
        emit NotaGuardada(alumno, materia, nota);
    }
}
