// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract TokenDesdeCero {
    /**
        METODOS DE LECTURA
        - name: devolvia el nombre del token
        - symbol: devolvia el symbolo del token
        - decimals: devuelve la cantidad de decimales
        - totalSuppy: devuelve el total acuñado
        - balanceOf(address billetera): devuelve el balance de tokens de una billetera
            argumentos:
                - billetera a consultar
            return:
                - balance de la billetera
        - allowance(address owner, address spender): permite saber el permiso que se otorgo a una address
            argumentos:
                - owner (dueño) de los tokens
                - spender (gastador) el que va a gastar los tokens
            return:
                - cantidad de permiso

        METODOS DE ESCRITURA
        - mint(address to, uint256 amount): acuña Q tokens a una billetera (EOA y SCA)
            argumentos:
                - to (destinatario) a recibir los tokens
                - amount: cantidad de tokens a acuñar

        - approve(address spender, uint256 amount): da permiso a una billetera en una cierta Q
            argumentos:
                - spender (gastador): addres que va a gastar los tokens
                - amount cantidad de tokens a gastar

        - transfer(address to, uint256 amount): transfiere tokens del owner a la billetera 'to'
            argumentos:
                - to (destinatario) a recibir la transferencia de tokens
                - amount: cantidad de tokenes a transferir

        - transferFrom(address from, address to, uint256 amount)
            argumentos:
                - from (dueño de los tokens): a quien se le quitan los tokens
                - to (destinatario): el que recibe los tokens de la transferencia
                - amount: cantidad de tokens a enviar
    */

    // - name: devolvia el nombre del token
    function name() public pure returns (string memory) {
        return "Lee Marreros Token";
    }

    // - symbol: devolvia el symbolo del token
    function symbol() public pure returns (string memory) {
        return "LMRRTKN";
    }

    // - decimals: devuelve la cantidad de decimales
    function decimals() public pure returns (uint256) {
        return 18;
    }

    // - totalSuppy: devuelve el total acuñado
    uint256 public totalSuppy;

    // - balanceOf(address billetera): devuelve el balance de tokens de una billetera
    //     argumentos:
    //         - billetera a consultar
    //     return:
    //         - balance de la billetera
    mapping(address billetera => uint256 balance) balances;

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    // - mint(address to, uint256 amount): acuña Q tokens a una billetera (EOA y SCA)
    //     argumentos:
    //         - to (destinatario) a recibir los tokens
    //         - amount: cantidad de tokens a acuñar
    function mint(address to, uint256 amount) public {
        balances[to] += amount;
        totalSuppy += amount;
    }
}
