// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "hardhat/console.sol";

/**
REPETIBLE CON LÍMITE, PREMIO POR REFERIDO

* El usuario puede participar en el airdrop una vez por día hasta un límite de 10 veces
* Si un usuario participa del airdrop a raíz de haber sido referido, el que refirió gana 3 días adicionales para poder participar
* El contrato Airdrop mantiene los tokens para repartir (no llama al `mint` )
* El contrato Airdrop tiene que verificar que el `totalSupply`  del token no sobrepase el millón
* El método `participateInAirdrop` le permite participar por un número random de tokens de 1000 - 5000 tokens
*/

/*
Ojo: 
Luego del deploy del Airdrop, el dueño del token le da 100000 * 10**18 de tokens via mint, al Airdrop.
Con ello se entiende el enunciado: El contrato Airdrop mantiene los tokens para repartir (no llama al `mint` )
    
    await miPrimerToken.mint(
      await airdropTwo.getAddress(),
      ethers.parseEther("100000")       //es decir 100 000 * 10**18  (cien mil de los Tokens)
    );

Notar que miPrimerToken.mint no es llamado con miPrimerToken.connect(x).mint, lo cual significa que quien llama es el owner del Token,
a quien se le dió el role de Minter en el constructor del Token
*/

interface IMiPrimerTKN {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    //No es necesario pues el Airdrop no acuña 'nuevos' Tokens, por lo que no puede variar el totalSupply del Token
    //function totalSupply() external view returns (uint256);
}

contract AirdropTwo is Pausable, AccessControl {

    // instanciamos el token en el contrato
    IMiPrimerTKN miPrimerToken;

    uint256 public constant totalAirdropMax = 10 ** 6 * 10 ** 18; // 1 000 000 * 10**18

    constructor(address _tokenAddress) {
        miPrimerToken = IMiPrimerTKN(_tokenAddress);

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    uint256 totalRepartidos;//o totalSupply

    struct Participante{
        address cuentaParticipante;
        uint256 participaciones;
        uint256 limiteParticipaciones;
        uint256 ultimaVezParticipado;
        uint256 balance;
    }

    mapping(address => Participante) public participantes;

    function participateInAirdrop() public {
        Participante storage participante = participantes[msg.sender];

        if(participante.limiteParticipaciones==0){
           participante.limiteParticipaciones = 10; 
        }
        require(block.timestamp > participante.ultimaVezParticipado + 1 days, "Ya participaste en el ultimo dia");
        participante.ultimaVezParticipado = block.timestamp;
        require(participante.participaciones + 1 <= participante.limiteParticipaciones, "Llegaste limite de participaciones");
        participante.participaciones++;
        
        uint256 nrotokens = _getRadomNumber10005000(); //ejem: 2000

        // En un principio, segun el Testing.js, al Airdrop se le acuña 100000 * 10 ** 18 tokens (cien mil Tokens)
        // Es decir su balance inicial del Airdrop es de cien mil tokens, pero luego va disminuyendo a medida que va transfiriendo tokens a los participantes
        require((totalRepartidos + nrotokens <= miPrimerToken.balanceOf(address(this))),  "El contrato Airdrop no tiene tokens suficientes");

        // Enunciado: El contrato Airdrop tiene que verificar que el `totalSupply` del token no sobrepase el millón
        // El Airdrop no acuña ni quema tokens, por lo que no puede variar el totalSupply del Token.
        // Definicion de totalSupply: Returns the amount of tokens in existence. Y este se incrementa llamando a mint, y se disminuye llamando a burn.
        // require(miPrimerToken.totalSupply() <= 1000000 * 10**18, "El 'totalSupply' del token supera el millon");

        //- balance inicial del airdrop = 100 mil
        //- politica del airdrop es solo repartir hasta 1 millon (en caso el dueño del token le acuñe mas tokens al airdrop)
        require(totalRepartidos + nrotokens <= totalAirdropMax, "Error: Ha sobrepasado el millon de Tokens");

        totalRepartidos += nrotokens;
        participante.balance += nrotokens;//el participante puede participar varias veces
        
        //Por participar, se transfiere nrotokens del Airdrop al participante:
        miPrimerToken.transfer(msg.sender, nrotokens);

        /*
        console.log(miPrimerToken.balanceOf(address(this)));
        console.log(miPrimerToken.balanceOf(msg.sender));//console.log(participante.balance); //es igual
        */
    }

    function participateInAirdrop(address _elQueRefirio) public {
        require(msg.sender != _elQueRefirio, "No puede autoreferirse");

        participateInAirdrop();

        Participante storage participante = participantes[_elQueRefirio];
        if(participante.limiteParticipaciones==0){
            participante.limiteParticipaciones = 13;
        }
        else{
            participante.limiteParticipaciones += 3;
        }
    }

    /*
    mapping(address => uint256) participaciones;
    mapping(address => uint256) public limiteParticipaciones;
    mapping(address => uint256) ultimaVezParticipado;
    */

    ///////////////////////////////////////////////////////////////
    ////                     HELPER FUNCTIONS                  ////
    ///////////////////////////////////////////////////////////////

    function _getRadomNumber10005000() internal view returns (uint256) {
        return
            (uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) %
                4000) +
            1000 +
            1;
    }

    function setTokenAddress(address _tokenAddress) external {
        miPrimerToken = IMiPrimerTKN(_tokenAddress);
    }

    /*
        Es para que el creador o dueño del AirDrop, lo llame y se envíe a su billetera todo el saldo del Airdrop
        Notar que solo lo puede llamar quien tenga el ADMIN_ROLE, y en el constructor del Airdrop se le da ese rol al creador del Airdrop
    
        // extrae todos los tokens
        await airdropTwo.transferTokensFromSmartContract();
    */
    function transferTokensFromSmartContract()
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        miPrimerToken.transfer(
            msg.sender,
            miPrimerToken.balanceOf(address(this))
        );
    }
}
