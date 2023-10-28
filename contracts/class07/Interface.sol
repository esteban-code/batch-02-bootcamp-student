// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Interfaces
// 1 - Como una puerta  otros contratos
//     Heredar la inteface no tiene lugar o alguna aplicación

// 2 - Es una camisa fuerza (reglas autoaplicables)
//     Se debe heredar la interface para aplicar las reglas

// Derivando la interface de un contrato
// - Se definen como los métodos del contrato sin cuerpo
// - Se incluyen las firmas (la primera línea) de los metodos del contrato
// - La unica visibilidad posible es 'external'
// - I al inicio para indicar que es interfaz
// - La inteface está fuera de todo contrato
// - ¿De qué metodos puedo crear sus interfaces? Solo de aquellos métods 'public' o 'external'
interface IEleccion {
    function votar(uint256 candidato) external;

    function consultarConteo() external view;
}

contract Eleccion {
    // uint256 total;
    mapping(uint256 candidato => uint256 voto) public votos;

    function votar(uint256 candidato) public {
        // operaciones
        votos[candidato]++;
        // total++;
    }

    function consultarConteo() public view {}
}

// El contrato Votante va a comunicarse con el contrato Eleccion
// El contrato Votante usará los métodos 'votar' y 'consultarConteo' de Eleccion
// Para comunicarme con otro contrato debo crear una referencia al otro contrato
contract Votante {
    // contratoEleccion es una refencia a Eleccion
    // contratoEleccion puede usar los metodos de Eleccion
    IEleccion contratoEleccion =
        IEleccion(0xDf9D0C45d97f134151a386E0AA23b09CA903c13f);

    function votarComoVotante() public {
        contratoEleccion.votar(100);
    }

    function consultarConteoGeneral() public {}
}
