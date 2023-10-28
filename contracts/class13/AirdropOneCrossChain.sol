// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract AirdropOneCrossChain is Pausable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    uint256 public constant totalAirdropMax = 10 ** 6 * 10 ** 18;
    uint256 public constant quemaTokensParticipar = 10 * 10 ** 18;

    uint256 airdropGivenSoFar;

    mapping(address => bool) public whiteList;
    mapping(address => bool) public haSolicitado;

    event MintInAnotherChain(address account, uint256 tokens);
    event BurnCrossChain(address account, uint256 tokens);

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
    }

    function participateInAirdrop() public whenNotPaused {
        // pedir numero random de tokens
        uint256 tokensToReceive = _getRadomNumberBelow1000();

        // verificar que no se exceda el total de tokens a repartir
        require(
            airdropGivenSoFar + tokensToReceive <= totalAirdropMax,
            "No hay tokens disponibles"
        );

        // actualizar el conteo de tokens repartidos
        airdropGivenSoFar += tokensToReceive;
        // marcar que ya ha participado
        haSolicitado[msg.sender] = true;

        // emitir evento de transferencia
        emit MintInAnotherChain(msg.sender, tokensToReceive);
    }

    function quemarMisTokensParaParticipar() public whenNotPaused {
        // verificar que el usuario aun no ha participado
        require(haSolicitado[msg.sender], "Usted aun no ha participado");

        // emitir evento de quemar los tokens
        emit BurnCrossChain(msg.sender, quemaTokensParticipar);
    }

    function darOtroChance(
        address _account
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        haSolicitado[_account] = false;
    }

    ///////////////////////////////////////////////////////////////
    ////                     HELPER FUNCTIONS                  ////
    ///////////////////////////////////////////////////////////////

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _getRadomNumberBelow1000() internal view returns (uint256) {
        uint256 random = (uint256(
            keccak256(abi.encodePacked(block.timestamp, msg.sender))
        ) % 1000) + 1;
        return random * 10 ** 18;
    }
}
