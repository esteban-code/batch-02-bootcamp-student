// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract MsgSender {
    // msg.sender es una variable global
    //  - no se define en ningún (es dado por solidity)
    //  - representa a la billetera que hace la transacción
    //  - "msg.sender es quien esta interactuando con el contrato actualmente" ~ Genaro Molina
    // Otras variables globales:
    // - block.timestamp: segundo en el que bloque se añade a la cadena de bloques
    // - msg.value: cantidad de tokens nativos que se envían

    // 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    // 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    address public elQueLlama;

    function setCaller() public {
        elQueLlama = msg.sender;
    }

    //  ACOTACIÓN:
    //  Cada blockchain tiene un token nativo (se llama de manera diferente)
    //          Blockchain              |           token nativo (nombre)
    //              Ethereum                            Ether
    //              Polygon                             MATIC
    //              Binance                             BNB
    // tokens nativos != tokens ERC20, NFTs
    // Token nativo es creado por el propio blockchain ( no se necesita un contrato inteligente)
    // Tokens no nativos se crean a través de contratos Inteligentes:
    //  - USDC
    //  - Tether
    //  - BUSD
}
