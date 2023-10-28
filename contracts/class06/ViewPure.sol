// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Pure {
    uint256 age = 200;

    // no te permite leer estados del contrato inteligente
    // tampoco te permite realizar cambios de estado
    // metodo de lectura (sin leer variables del contrato)
    // no se puede pasar una variable del contrato como parametro
    function functionPure() public pure returns (uint256) {
        // return age; X no se puede porque lee el estado del contrato
        // age = 234234; X no se puede escribir estados del contrato
        return 23432423;
    }

    function functionPure2(uint256 _a) internal pure returns (uint256) {
        // realizar calculo complejo con parametro inyectado
        return _a * 10 ** 4;
    }

    function functionPure3() external pure returns (string memory) {
        return "funciton pura";
    }

    // Una function pure puede llamar a otra funcion pure
    function functionPureQueLlamaAOtroPure() public pure returns (uint256) {
        return 11 * functionPure();
    }

    function functionView() public view returns (uint256) {
        return age;
    }
    // No se puede hacer porque functionView lee del contrato inteligente
    // function functionPureQueLlamaView() public pure returns(uint256) {
    //     return functionView();
    // }
}
