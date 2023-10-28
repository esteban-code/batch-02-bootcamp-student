// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract ContratoASerLlamado {
    mapping(address => bool) public listaBlanca;

    function addToWhiteList(address _account) public {
        listaBlanca[_account] = true;
    }
}

/**
    DELEGATE CALL
    - Cuando un contrato A se presta código de un contrato B para ejecutarlo en A
    - El contrato A llama a los métodos del contrato B en el contexto del contrato A
    - El contexto del contrato A se preserva cuando A usa los métodos del contrato B
    - "No se puede accede al mapping porque no esta definido". SIN EMBARGO, eso no impide leerlo del slot
    - A usa el storage layout del contrato B en el contexto del contrato A
    - La información se guarda en el contrato A. De B no se toca el storage
    - storaga layout: plano de memoria permanente
    - A usa el plano de memoria de B para guardar su información en A usando métodos de B
    Nota: "contexto" hago referencia al storage y variables globales de A
*/
contract ContratoQueVaALlamar {
    function addToWhiteListOtroContrato(address _sc, address _account) public {
        (bool success, ) = _sc.delegatecall(
            abi.encodeWithSignature("addToWhiteList(address)", _account)
        );
        require(success);
    }

    function obtenerValorDeCasillero(
        uint256 _posCasillero
    ) public view returns (uint256) {
        uint256 valorCasillero;
        assembly {
            valorCasillero := sload(_posCasillero)
        }
        return valorCasillero;
    }

    function obtenerCasilleroParaMapping(
        uint256 _slotInicial,
        address _key
    ) public pure returns (uint256) {
        return uint256(keccak256(abi.encode(_key, _slotInicial)));
    }
}
