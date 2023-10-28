// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Owner {
    address private owner = msg.sender;
    modifier onlyOwner() {
        require(owner == msg.sender, "No eres el owner");
        _;
    }
}

contract Paused {
    bool private paused;
    modifier cuandoNoPausado() {
        // whenNotPaused
        require(!paused, "Esta pausado");
        _;
    }

    function _pause() internal {
        paused = true;
    }

    function _unpause() internal {
        paused = false;
    }
}

contract HerenciaModifiers is Owner, Paused {
    bool paused;

    function protegerMetodo() public onlyOwner cuandoNoPausado {}

    function protegerMetodo2() public onlyOwner cuandoNoPausado {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}

contract HerenciaModifiers2 is Owner {
    address owner;
}
