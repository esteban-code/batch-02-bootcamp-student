// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract StorageSlots {
    uint256 private year = 2023; // slot 0
    bool private encendido = true; // slot 1
    uint256 public month = 12; // slot 2

    uint256[] numbers = [uint256(1), 2, 3, 4, 5]; // slot 3
    //              ix      0        1  2  3  4

    mapping(address => bool) listaBlanca; // slot 4

    constructor() {
        listaBlanca[msg.sender] = true;
        listaBlanca[0x0d6968f6275804a4F6593f939DA09F08C49020ba] = true;
    }

    function obtenerValorDeCasillero(
        uint256 _posCasillero
    ) public view returns (uint256) {
        uint256 valorCasillero;

        // Mal llamado assembly. En realidade es Yul
        assembly {
            valorCasillero := sload(_posCasillero)
        }
        return valorCasillero;
    }

    function obtenerCasilleroParaArray(
        uint256 _slotInicial,
        uint256 _indexDeArray
    ) public pure returns (uint256) {
        // return hash(slot) + indiceArray
        return uint256(keccak256(abi.encode(_slotInicial))) + _indexDeArray;
    }

    function obtenerCasilleroParaMapping(
        uint256 _slotInicial,
        address _key
    ) public pure returns (uint256) {
        // return hash(_key, _slotInicial)
        return uint256(keccak256(abi.encode(_key, _slotInicial)));
    }
}
