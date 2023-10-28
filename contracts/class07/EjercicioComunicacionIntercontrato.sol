// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Comunicación Intercontrato
// 1. Derivar la interfaz (incluir en la interface los métodos que quieres usar)
// 2. Publicar el contrato Asistencia (si es que no esta publicado)
// 3. Obtener el address del contrato Asistencia
// 4. En el contrato que llamar, crear una referencia de Asistencia
// 5. Usar los metodos definidos en la interface

// 1
interface IAsistencia {
    function marcarAsistencia(address _estudiante) external;

    function leerAsistencia(address _estudiante) external view returns (bool);

    function metodoQueNoExist() external;
}

//3. 0x09197b6faf9f5ADE46D476A0061F0119FB681367
contract Asistencia {
    mapping(address estudiante => bool siAsistio) public asistentes;

    function marcarAsistencia(address _estudiante) public {
        asistentes[_estudiante] = true;
    }

    function leerAsistencia(address _estudiante) public view returns (bool) {
        return asistentes[_estudiante];
    }

    function otrosMetodos() public {}

    function otrosMetodos2() public {}

    function otrosMetodos3() public {}

    function otrosMetodos4() public {}
}

contract Estudiante {
    // 4
    // Creando referencia en storage
    IAsistencia asistencia =
        IAsistencia(0x09197b6faf9f5ADE46D476A0061F0119FB681367);

    function marcar() public {
        // Usar el contrato Asistencia para llamar al metodo marcarAsistencia
        asistencia.marcarAsistencia(msg.sender);
    }

    function marcar2(address contratoAddress) public {
        // Comunicación a otro contrato (dinámico)
        // (A la volada)
        IAsistencia(contratoAddress).marcarAsistencia(msg.sender);
    }

    function leer() public view returns (bool) {
        return asistencia.leerAsistencia(msg.sender);
    }

    function llamarAMetodoQueNoExiste() public {
        asistencia.metodoQueNoExist();
    }
}

// struct y eventos en interface
// Segunda aplicación - camisa de fuerza
interface ICompleja {
    event Complejo();

    struct DatoComplejo {
        address billetera;
    }
}

contract ContratoComplejo is ICompleja {}
