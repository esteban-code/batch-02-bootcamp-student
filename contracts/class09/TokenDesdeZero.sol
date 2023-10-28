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

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

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

    // NO FORMA PARTE DEL ESTANDAR ERC20 (su implementación no es obligatoria)
    // - mint(address to, uint256 amount): acuña Q tokens a una billetera (EOA y SCA)
    //     argumentos:
    //         - to (destinatario) a recibir los tokens
    //         - amount: cantidad de tokens a acuñar
    function mint(address to, uint256 amount) public {
        balances[to] += amount;
        totalSuppy += amount;

        emit Transfer(address(0), to, amount);
    }

    function burn(uint256 amount) public {
        balances[msg.sender] -= amount;
        totalSuppy -= amount;

        emit Transfer(msg.sender, address(0), amount);
    }

    function _burnTokensDeSC(uint256 amount) private {
        balances[address(this)] -= amount;
        totalSuppy -= amount;
    }

    // - transfer(address to, uint256 amount): transfiere tokens del owner a la billetera 'to'
    //     argumentos:
    //         - to (destinatario) a recibir la transferencia de tokens
    //         - amount: cantidad de tokenes a transferir
    // uint256 fee = amount * 90 / 100;
    // uint256 net = amount - fee;
    // balances[address(this)] += fee;
    // _burnTokensDeSC(fee);
    function transfer(address to, uint256 amount) public {
        _transfer(msg.sender, to, amount);
    }

    // - transferFrom(address from, address to, uint256 amount)
    //     argumentos:
    //         - from (dueño de los tokens): a quien se le quitan los tokens
    //         - to (destinatario): el que recibe los tokens de la transferencia
    //         - amount: cantidad de tokens a enviar
    function transferFrom(address from, address to, uint256 amount) public {
        // validar: el que llama (gastador) tiene que tener permiso
        uint256 spenderPermiso = permisos[from][msg.sender];
        require(spenderPermiso >= amount, "No tienes suficiente permiso");
        // actualizar el permiso luego de usarlo
        permisos[from][msg.sender] -= amount;

        _transfer(from, to, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "Enviando desde Address Zero");
        require(to != address(0), "Enviando a Address Zero");

        uint256 balanceFrom = balances[from];
        require(balanceFrom >= amount, "No tiene suficiente balance");

        balances[from] -= amount;
        balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    // - approve(address spender, uint256 amount): da permiso a una billetera en una cierta Q
    //     argumentos:
    //         - spender (gastador): addres que va a gastar los tokens
    //         - amount cantidad de tokens a gastar
    /**
                                        SPENDER
                            0xAgus      0xAna       ......
        OWNER   0xAle       100         200
                0xLee        0          1000
    */
    mapping(address owner => mapping(address spender => uint256 qPermiso)) permisos;

    function approve(address spender, uint256 amount) public {
        permisos[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
    }

    // - allowance(address owner, address spender): permite saber el permiso que se otorgo a una address
    //     argumentos:
    //         - owner (dueño) de los tokens
    //         - spender (gastador) el que va a gastar los tokens
    //     return:
    //         - cantidad de permiso
    function allowance(
        address owner,
        address spender
    ) public view returns (uint256) {
        return permisos[owner][spender];
    }
}
