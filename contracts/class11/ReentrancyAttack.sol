// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Victim {
    constructor() payable {}

    mapping(address => uint256) public balances;

    function withdrawHackeable() public {
        uint256 amount = balances[msg.sender];
        require(amount > 0);

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success);

        balances[msg.sender] = 0;
    }

    bool reentrant;
    modifier nonReentrant() {
        require(!reentrant, "No permite reentrar");
        reentrant = true;
        _;
        reentrant = false;
    }

    function withdraw() public nonReentrant {
        // Patrón: checks effecta interaction

        // checks
        // validación de inputs o balances
        uint256 amount = balances[msg.sender];
        require(amount > 0);

        // effects
        // actualización de los balances
        balances[msg.sender] = 0;

        // interaction (interaccion con otros contratos)
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success);
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }
}

interface IVictim {
    function withdraw() external;

    function deposit() external payable;
}

/**
    Ataque de reentrante
    - El punto de partida es que se cede el control de la ejecución a otro contrato (mal actor)
    - El mal actor puede volver a reentrar a otro método sin que termine de ejecutarse
    - Solución: checks - effects - interaction 
    - Solución: modifier 'nonReentrant'
*/

contract Atacante {
    IVictim victim;

    constructor(address victimAddress) payable {
        victim = IVictim(victimAddress);
    }

    function attack() public {
        victim.deposit{value: 1 ether}();
        victim.withdraw();
    }

    receive() external payable {
        // Al ingresar al receive, el contrato Atacanta
        // tiene el control de la ejecución
        // Dentro de este metodo receive se puede volver a llamar a withdraw()
        address victimAddress = address(victim);
        if (victimAddress.balance > 0) {
            victim.withdraw();
        }
    }
}
