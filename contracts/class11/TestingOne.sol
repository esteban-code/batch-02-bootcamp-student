// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestingOne is ERC20 {
    uint256 public year;
    uint256 public month;

    // 1
    constructor(
        uint256 _year,
        uint256 _month
    ) payable ERC20("Testing One", "TSTNONE") {
        year = _year;
        month = _month;
    }

    // 2 - msg.sender
    address public caller;

    function setYearAndMonth(uint256 _year, uint256 _month) public {
        year = _year;
        month = _month;
        caller = msg.sender;
    }

    event Caller(address account);
    event CallerAndState(address account, uint256 year, uint256 month);

    function fireEvents() public {
        emit Caller(msg.sender);
        emit CallerAndState(msg.sender, year, month);
    }

    uint256 input;

    function validarInput(uint256 _input) public {
        require(_input >= 1000, "Input Incorrecto");
        input = _input;
    }

    error WrongInput();
    error WrongInputWithArgs(uint256 wrongInput);

    function validarInput2(uint256 _input) public {
        if (_input < 1000) revert WrongInput();
        input = _input;
    }

    function validarInput3(uint256 _input) public {
        if (_input < 1000) revert WrongInputWithArgs(_input);
        input = _input;
    }

    // Transferencias de Ether
    function enviarEther() public payable {}

    function reclamarEther(uint256 _etherAmount) public {
        payable(msg.sender).transfer(_etherAmount);
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
