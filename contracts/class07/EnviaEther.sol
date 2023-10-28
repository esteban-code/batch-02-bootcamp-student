// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "hardhat/console.sol";

contract ReceiveAndFallback {
    event Receive(uint256 etherAmount);
    event Fallback(uint256 etherAmount);

    constructor() {}

    function reciveEther(address _account) public payable {
        // msg.value: cantidad de ether a enviar
        // logica compleja de cálculos
        // logica compleja de cálculos
        // logica compleja de cálculos
    }

    mapping(uint256 => bool) booleans;

    function consumeGas() public {
        for (uint256 i; i < 100; i++) {
            booleans[i] = true;
        }
    }

    // Para aquellas personas que solo quieren enviar Ether sin hacer cálculos complejos
    receive() external payable {
        emit Receive(msg.value);
    }

    // msg.value variable global que captura cuanto ether se envia al contrato
    fallback() external payable {
        emit Fallback(msg.value);
    }
}

contract Sender {
    constructor() payable {}

    // 1 - transfer
    // Enviando ether de Sender a ReceiveAndFallback usando transfer
    // Cuando se transfiere ether se asigna un presupuesto de 2300 de gas
    //  a ser gastado en el contrato que recibe Ether.
    // Si el contrato que recibe tiene operaciones superiores a 2300 de gas
    //  la operación se revierte.
    // ¿Qué alcanza con 2300 de gas? Sirve para emitir un evento. O cambiar el estado de una variable
    // Usando transfer podemos prevenir el Reentrancy Attack
    function transfer(address _scAddres, uint256 _amount) public {
        // MANERA INCORRECTA DE LEER: el address _scAddres va a transferir la cantidad de _amount
        // MANERA CORRECTA: al address _scAddres se le va a transferir la cantidad de _amount
        payable(_scAddres).transfer(_amount);
    }

    // 2 - send
    // Devuelve un boolean indicando el éxito de la operación
    // El presupuesto que asigna al contrato que recibe el Ether es de 2300
    // Usando transfer podemos prevenir el Reentrancy Attack
    function send(address _scAddres, uint256 _amount) public {
        // MANERA CORRECTA: al address _scAddres se le va a enviar la cantidad de _amount
        bool success = payable(_scAddres).send(_amount);
        // require(success, "Transferencia fallida");
        // Otras operaciones
        console.log(success);
    }

    // 3 - call
    // Puedo transferir Ether
    // Puedo definir la cantidad de gas a gastar en el contrato que recibe el Ether
    // Puedo decidir si ejecuto un método del otro contrato
    // Low-level function
    // Tiene valores de retorno: success y la razon por qué fallo
    //  - son success puedes tener una logica posterior en caso falle
    //  - tienes el control en caso falle la transacción
    //  - entender por qué falló con 'error'
    // {value: _amount, gas: 500000}:
    //  - value: la cantidad de Ether que quiero enviar
    //  - gas: el presupuesto de gas a asignar para el otro contrato
    // Abre la puerta al ataque de REENTRADA
    function call(address _scAddress, uint256 _amount) public {
        (bool success, ) = payable(_scAddress).call{
            value: _amount,
            gas: 5000000
        }("");
        require(success, "Fallo la transferencia");
    }

    // Llamando a reciveEther del contrato ReceiveAndFallback
    // Si envias Ether a un método, el método debe ser payable
    function callUsandoUnMetodoQueExiste(
        address _scAddress,
        uint256 _amount
    ) public {
        (bool success, ) = payable(_scAddress).call{
            value: _amount,
            gas: 5000000
        }(abi.encodeWithSignature("reciveEther(address)", msg.sender));

        require(success, "Fallo la transferencia");
    }
}
