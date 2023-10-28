// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract ContratoLlamante {
    uint256 public respuestaDeFallback;

    function llamandoAContratoFallback(address _sc) public {
        (bool success, bytes memory output) = _sc.call(
            abi.encodeWithSignature("metodoQueNoExiste()")
        );
        require(success);
        respuestaDeFallback = abi.decode(output, (uint256));
    }
}

contract ContratoConFallback {
    uint256 public counter;
    bytes public input;

    fallback(bytes calldata _input) external returns (bytes memory _output) {
        input = _input;
        counter++;
        _output = abi.encode(counter);
    }
}
