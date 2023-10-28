// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// 0xf8e81D47203A594245E36C48e151709F0C19fBe8
contract ReceiveAndFallBackExercise {
    event Receive();
    event Fallback();
    event MetodoExiste();

    function metodoQueRecibeEther(address) public payable {
        emit MetodoExiste();
    }

    receive() external payable {
        emit Receive();
    }

    // fallback(bytes calldata params) external payable returns (bytes memory) {
    fallback() external payable {
        // () = abi.decode(params, [address, uint256, string]);
        emit Fallback();
    }

    function metodoConPayable() public payable {
        // msg.value
        if (msg.value == 0) {
            // operaciones 1
        } else if (msg.value == 1 ether) {
            // operaciones 2
        } else if (msg.value > 1 ether) {
            uint256 vuelto = msg.value - 1 ether;
            payable(msg.sender).transfer(vuelto);
        }
    }
}

contract SenderExercise {
    address receiveContract = 0xf8e81D47203A594245E36C48e151709F0C19fBe8;

    constructor() payable {}

    // Disparando el receive del otro contrato
    function disparandoReceive() public {
        payable(receiveContract).transfer(1 ether);
    }

    function disaparandoFallback() public {
        (bool success, ) = payable(receiveContract).call{value: 1 ether}(
            abi.encodeWithSignature(
                "methodQueNoExiste(address,uint256,string)",
                msg.sender,
                123123,
                "Hello"
            )
        );
        require(success);
    }

    function disparandoOtroMetodo() public {
        (bool success, ) = payable(receiveContract).call{value: 1 ether}(
            abi.encodeWithSignature("metodoQueRecibeEther(address)", msg.sender)
        );
        require(success);
    }

    function retornarAbi() public view returns (bytes memory) {
        // 0x550b16be0000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc4
        return
            abi.encodeWithSignature(
                "metodoQueRecibeEther(address)",
                msg.sender
            );
    }
}
