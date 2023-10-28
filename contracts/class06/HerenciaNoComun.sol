// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Abuelo {
    uint256 edadAbuelo = 2023;

    // visibilidad external
    // - no se puede usar desde dentro del contrato
    // - Solo permite llamadas fuera del contrato
    // - SÍ SE PUEDEN HEREDAR
    function publicView() external view virtual returns (uint256) {
        return edadAbuelo;
    }

    function externalPure() external view virtual returns (uint256) {
        return edadAbuelo;
    }

    function reemplazarPorUnaVarible() external view virtual returns (uint256) {
        return edadAbuelo;
    }
}

contract Padre is Abuelo {
    function publicView() public view override returns (uint256) {}

    function externalPure() external pure override returns (uint256) {}

    uint256 public override reemplazarPorUnaVarible = 1000000;
}
