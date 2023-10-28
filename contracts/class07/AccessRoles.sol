// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract OnlyOwner {
    address owner = msg.sender;

    modifier onlyOwner() {
        require(msg.sender == owner, "No eres el Owner");
        _;
    }
}

contract X is OnlyOwner {
    function protegerMetodo() public onlyOwner {}

    function protegerMetodo2() public onlyOwner {}

    function protegerMetodo3() public onlyOwner {}

    function protegerMetodo4() public onlyOwner {}
}

// Acceso granular
contract AccessRoles {
    /**
    mint: acuñar
    | ROLES     | MINTER | BURNER | PAUSER |
    | --------- | ------ | ------ | ------ |
    | Account 1 | True   | True   | True   |
    | Account 2 | True   | False  | True   |
    | Account 3 | False  | False  | True   |
    */
    /**
    // bytes32: nos ayuda a guardar un hash
    mapping(address billetera => mapping(bytes32 role => bool tieneAcceso)) roles;

    function otorgarRole(address _account, bytes32 _role) public {
        roles[_account][_role] = true;

        // roles[Account 1][MINTER] = true;
    }
    otorgarRole(Account 1, MINTER)
    otorgarRole(Account 1, BURNER)
    otorgarRole(Account 1, PAUSER)
    otorgarRole(Account 2, MINTER)
    otorgarRole(Account 2, PAUSER)
    otorgarRole(Account 3, PAUSER)

    function retirarRole(address _account, bytes32 _role) public {
        roles[_account][_role] = false;
        // delete roles[_account][_role];
    }
    retirarRole(Account 3, PAUSER)
    */

    // 0x0000000000000000000000000000000000000000000000000000000000000000
    bytes32 public DEFAULT_ADMIN_ROLE = 0x00;

    /**
    mint: acuñar
    | ROLES     | ADMIN  | BURNER | PAUSER |
    | --------- | ------ | ------ | ------ |
    | Account 1 | True   | True   | True   |
    | Account 2 | True   | False  | True   |
    | Account 3 | False  | False  | True   |
    */
    modifier onlyRole(bytes32 _role) {
        require(roles[msg.sender][_role], "No tienes ese role");
        _;
    }

    constructor() {
        // de manera anticipada marqué como admin al que publicó el contrato
        roles[msg.sender][DEFAULT_ADMIN_ROLE] = true;
    }

    mapping(address billetera => mapping(bytes32 role => bool tieneAcceso)) roles;

    function grantRole(
        address _account,
        bytes32 _role
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        roles[_account][_role] = true;
    }

    function revokeRole(
        address _account,
        bytes32 _role
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        roles[_account][_role] = false;
    }

    function transferAdminRole(
        address _to
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        // el admin otorga ADMIN ROLE a otra address
        roles[_to][DEFAULT_ADMIN_ROLE] = true;
        // el admin renuncia a ADMIN ROLE
        roles[msg.sender][DEFAULT_ADMIN_ROLE] = false;
    }
}

contract ProtegerConroles is AccessRoles {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE"); //0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant NUEVO_ROLE = keccak256("NUEVO_ROLE");

    // bytes32 - Hash evita las colisiones
    // bytes32 - Esta optimizado para cabar en un casillero del contrato inteligente
    //           (dentro del SC existen 2^256 casilleros para guardar información)
    //           (cada casillero tiene un tamaño de 32 bytes)
    string ADMIN_ROLE = "ADMIN_ROLE_JULIO_2023_LIMA_SOUTH_AMERICA"; // es muy pesado- ocupa 2 casilleros
    bytes32 ADMIN_ROLE2 = keccak256("ADMIN_ROLE_JULIO_2023_LIMA_SOUTH_AMERICA");

    function protegerPorRolMinter() public onlyRole(MINTER_ROLE) {}

    function protegerPorRolBurner() public onlyRole(BURNER_ROLE) {}

    function protegerPorRolNuevoRole() public onlyRole(NUEVO_ROLE) {}
}
