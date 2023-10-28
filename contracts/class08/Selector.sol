// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IEleccion {
    function votar(uint256 candidato) external;
}

// hash metodo: 21606831cff9e02a36879121b90daa10ae1ecfcb18b21e80a8c26ab7420b287c
contract ObtenerSelector {
    function getSelector() external pure returns (bytes4) {
        return IEleccion.votar.selector;
    }

    function getSelectorManual() external pure returns (bytes4) {
        return bytes4(keccak256("votar(uint256)"));
    }

    // 0x550b16be0000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc4
    // return abi.encodeWithSignature("metodoQueRecibeEther(address)", msg.sender);
}
