// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract TokenGenerico is IERC20 {
    // IERC20().transfer <= XXXXXXX
    string nombreDelToken;
    string simboloToken;

    constructor(string memory _nombreDelToken, string memory _simboloToken) {
        nombreDelToken = _nombreDelToken;
        simboloToken = _simboloToken;
    }

    function name() public view returns (string memory) {
        return nombreDelToken;
    }

    function symbol() public view returns (string memory) {
        return simboloToken;
    }

    function decimals() public pure virtual returns (uint256) {
        return 18;
    }

    uint256 public totalSupply;

    mapping(address billetera => uint256 balance) balances;

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function mint(address to, uint256 amount) public {
        balances[to] += amount;
        totalSupply += amount;

        emit Transfer(address(0), to, amount);
    }

    function burn(uint256 amount) public {
        balances[msg.sender] -= amount;
        totalSupply -= amount;

        emit Transfer(msg.sender, address(0), amount);
    }

    function _burnTokensDeSC(uint256 amount) private {
        balances[address(this)] -= amount;
        totalSupply -= amount;
    }

    function transfer(
        address to,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    // function transferFrom(address from, address to, uint256 amount) external returns (bool);
    // .transferFrom()
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        uint256 spenderPermiso = permisos[from][msg.sender];
        require(spenderPermiso >= amount, "No tienes suficiente permiso");
        permisos[from][msg.sender] -= amount;

        _transfer(from, to, amount);

        return true;
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

    mapping(address owner => mapping(address spender => uint256 qPermiso)) permisos;

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        permisos[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view returns (uint256) {
        return permisos[owner][spender];
    }
}

contract BBTKN is TokenGenerico {
    constructor() TokenGenerico("Blockchain B. Token", "BBTKN") {}

    function decimals() public pure override returns (uint256) {
        return 6;
    }

    function aidrop() public {}

    function aidrop2() public {}

    function aidrop3() public {}
}

/**
 * ¿Cómo se calcula el address de un contrato?
 * Se requiren dos insumos:
 *   - msg.sender
 *   - nonce (# de transacciones de msg.sender)
 * El nonce se incrementa y por lo tanto cada contrato tendrá un address diferente
 */
