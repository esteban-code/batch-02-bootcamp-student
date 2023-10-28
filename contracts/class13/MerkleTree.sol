// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MerkleTree is ERC721 {
    bytes32 public root;

    constructor() ERC721("Merkle Tree Airdrop", "MTA") {}

    function safeMint(
        address to,
        uint256 tokenId,
        bytes32[] memory proofs
    ) public {
        // Antes de acuñar vamos a validar pertenecia
        // Vamos a validar si to y tokenId son parte de la lista
        // verify()
        require(
            verify(_hashearInfo(to, tokenId), proofs),
            "No eres parte de la lista"
        );
        _safeMint(to, tokenId);
    }

    function _hashearInfo(
        address to,
        uint256 tokenId
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(tokenId, to));
    }

    function verify(
        bytes32 leaf,
        bytes32[] memory proofs
    ) public view returns (bool) {
        return MerkleProof.verify(proofs, root, leaf);
    }

    function verifyMerkleProof(
        bytes32 leaf,
        bytes32[] memory proofs
    ) public view returns (bool) {
        bytes32 computedHash = leaf;
        // proofs es un array de pruebas
        // evaluar su complejidad lexicografica
        // se calcula el hash con el elemento menos complejo a la izquierda
        // se calcula el hash con el elemento más complejo a la derecha

        for (uint256 i; i < proofs.length; i++) {
            bytes32 proof = proofs[i];

            if (computedHash < proof) {
                // computedHash va a la izquierda y proof a la derecha
                // hash(computed, proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proof));
            } else {
                computedHash = keccak256(abi.encodePacked(proof, computedHash));
            }
        }

        return computedHash == root;
    }

    function actualizarRaiz(bytes32 _root) public {
        root = _root;
    }
}
