// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract NumerosPseudoRandom {
    // Metodos de hasheo: keccak256
    // El keccak256 no acepta múltiples insumos para hashear
    // Entonces usamos abi.encodePacked para combinar insumos (valores)
    // El resultado de abi.encodePacked es el input de keccak256
    // El resultado de keccak256 no es un entero pero se puede caster
    // uint256(keccak256)

    uint256 nonce;

    function encontrarNumeroPseudoRandom() public view returns (uint256) {
        // nonce++;
        return
            uint256(
                keccak256(
                    abi.encodePacked(msg.sender, address(this), block.timestamp)
                )
            );
    }
}
