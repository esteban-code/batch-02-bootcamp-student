// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract View {
    uint256 a = 12312312312;

    event Number(uint256 number);

    // 'view'
    // - podemos leer variables del contrato (de estado)
    function functionView() public view returns (uint256) {
        return a;
    }

    // 'view'
    // - no podemos alterar ningún estado
    // - no podemos guardar información en el blockchain
    function functionView2() internal view returns (uint256) {
        // emit Number(a);
        return a;
    }

    function functionView3() external view returns (uint256) {
        // emit Number(a);
        return a;
    }
}
