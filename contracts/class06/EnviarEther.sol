// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract RecibeEther {
    uint256 public balanceEther;
    event Receive();
    event Fallback();

    // Cuando se publica "depositar" (se tranfiere) Ether en el contrato
    // 'payable' marca a un método para que reciba Ether
    // Si el método no tiene 'payable', la transacción se revierte si se le envía Ether
    constructor() payable {}

    function consultarBalanceEtherContrato() public view returns (uint256) {
        // this: este contrato
        // address(this): el address de este contrato
        // address(this).balance: el balance de ether de este contrato
        return address(this).balance;
    }

    function functionQueRecibeEther() public payable {}

    function functionQueNoRecibeEther() public {}

    // receive:
    // - sirve solamente para recibir ether
    // - Se prefiere usar receive por encima de fallback para recibir Ether
    // - Tiene precedencia para recibir Ether (por sobre fallback)
    // - no se ejecuta si envia ETHER y se ENVIA CÓDIGO
    receive() external payable {
        emit Receive();
    }

    // Se usa fallback para preparar al contrato para reicibir Ether
    // Era la única manera de hacerlo en versiones anteriores de Solidity
    // El método fallback se dispara cuando se llama al contrato con un método que no existe
    // Sí se ejecuta si se envía ETHER y se ENVÍA CODIGO
    // Balance de Ether
    // - La cuenta del balance de Ether se lleva automáticamente
    fallback() external payable {
        emit Fallback();
        // msg.value (variable global)
        // representa la cantidad de ether que se le envía al contrato
        balanceEther += msg.value;
    }
}

// Enviar Ether de manera forzosa a un contrato
// 1 - selfdestruct (su opcode) eventualmente se deprecará y causará breaking changes
contract SelfDestruct {
    constructor() payable {}

    function destruir(address payable _destino) public {
        selfdestruct(_destino);
    }
}
// 2 - en validación (el validador) se especifica un address que recibirá los beneficios
//      de haber ganado esa ronda para colocar su bloque
