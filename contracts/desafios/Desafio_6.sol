// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
LISTA BLANCA Y NÚMERO ALEATORIO

* Se necesita ser parte de la lista blanca para poder participar del Airdrop - done
* Los participantes podrán solicitar un número rándom de tokens de 1-1000 tokens
* Total de tokens a repartir es 10 millones
* Solo se podrá participar una sola vez
* Si el usuario permite que el contrato airdrop queme 10 tokens, el usuario puede volver a participar una vez más
* El contrato Airdrop tiene el privilegio de poder llamar `mint` del token
* El contrato Airdrop tiene el privilegio de poder llamar `burn` del token
*/

/*
OJO:
luego de ser deployado el Airdrop, el dueño del token le da permisos de mint y burn al airdrop
      
      // Set up Roles Token => Airdrop
      await miPrimerToken.grantRole(MINTER_ROLE, await airdropOne.getAddress());
      await miPrimerToken.grantRole(BURNER_ROLE, await airdropOne.getAddress());

*/

interface IMiPrimerTKN {
    function mint(address to, uint256 amount) external;

    function burn(address from, uint256 amount) external;

    function balanceOf(address account) external view returns (uint256);
}

contract AirdropOne is Pausable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    //Total de tokens a repartir es 10 millones
    //corrección: no es 10 ** 6 (1 millon) sino 10 ** 7 (10 millones)
    uint256 public constant totalAirdropMax = 10 ** 7 * 10 ** 18;//10 000 000 . 000 000 000 000 000 000

    //Si el usuario permite que el contrato airdrop queme 10 tokens, ...
    uint256 public constant quemaTokensParticipar = 10 * 10 ** 18;

    uint256 airdropGivenSoFar;

    address public miPrimerTokenAdd;

    mapping(address => bool) public whiteList;
    mapping(address => bool) public haSolicitado;

    constructor(address _tokenAddress) {
        miPrimerTokenAdd = _tokenAddress;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
    }

    function participateInAirdrop() public whenNotPaused {
        // lista blanca
        require(whiteList[msg.sender], "No esta en lista blanca");

        // ya solicitó tokens
        require(!haSolicitado[msg.sender], "Ya ha participado");
        // pedir número random de tokens
        uint256 tokensToReceive = _getRadomNumberBelow1000();

        // verificar que no se exceda el total de tokens a repartir
        require((airdropGivenSoFar + tokensToReceive) <= totalAirdropMax, "no se exceda el total de tokens a repartir");

        // actualizar el conteo de tokens repartidos
        airdropGivenSoFar += tokensToReceive;
        // marcar que ya ha participado
        haSolicitado[msg.sender] = true;

        // transferir los tokens
        // el airdrop llama para mintear los tokens para el participante, el participante tendra su balance en el Token
        // en este airdrop, el airdrop no mantiene balance en el Token, directamente llama a mint para mantener balance de los participantes en el Token
        IMiPrimerTKN miPrimerTokenTKN = IMiPrimerTKN(miPrimerTokenAdd);
        miPrimerTokenTKN.mint(msg.sender, tokensToReceive);

    }

    function quemarMisTokensParaParticipar() public whenNotPaused {
        // verificar que el usuario aun no ha participado
        require(haSolicitado[msg.sender], "Usted aun no ha participado");
        // Verificar si el que llama tiene suficientes tokens
        IMiPrimerTKN miPrimerTokenTKN = IMiPrimerTKN(miPrimerTokenAdd);
        require(miPrimerTokenTKN.balanceOf(msg.sender) >= quemaTokensParticipar, "No tiene suficientes tokens para quemar");
        // quemar los tokens
        miPrimerTokenTKN.burn(msg.sender, quemaTokensParticipar);
        // dar otro chance
        haSolicitado[msg.sender] = false;
    }

    ///////////////////////////////////////////////////////////////
    ////                     HELPER FUNCTIONS                  ////
    ///////////////////////////////////////////////////////////////

    function addToWhiteList(
        address _account
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        whiteList[_account] = true;
    }

    function removeFromWhitelist(
        address _account
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        whiteList[_account] = false;
    }

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

    function setTokenAddress(address _tokenAddress) external {
        miPrimerTokenAdd = _tokenAddress;
    }
}
