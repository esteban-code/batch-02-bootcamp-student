// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Modifiers {
    address public caller = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    uint256 public edad;

    modifier onlyCaller() {
        require(msg.sender == caller, "No esta autorizado");
        // require(msg.sender == caller, "No esta autorizado");
        // require(msg.sender == caller, "No esta autorizado");
        // require(msg.sender == caller, "No esta autorizado");
        _; // <- wildcard fusion: regresar al cuerpo del método o ir al siguiente modifier
    }

    // Digamos que quiero proteger este método
    function setAge(uint256 _edad) public onlyCaller {
        // msg.sender captura el address de quien el llama el contrato

        // Manera ingenua de proteger a un método
        // if (msg.sender != caller) return;

        edad = _edad;
    }

    function setAge2(uint256 _edad) public onlyCaller {}

    // function setAge3(uint256 _edad) public {
    // require(msg.sender == caller, "No esta autorizado");
    // }

    modifier validateRange(uint256 _edad) {
        require(_edad > 40 && _edad < 100, "Fuera del rango");
        _;
    }

    function setAgeWithRange(
        uint256 _edad
    ) public onlyCaller validateRange(_edad) {
        edad = _edad;
    }

    // timestamp: cantidad de segundos que pasaron desde 1 - 1 - 1970
    uint256 fechaLimite = 123124124124;
    modifier validarTiempo() {
        require(block.timestamp < fechaLimite);
        _;
    }

    function progetidoContraElTiempo() public validarTiempo {}

    // Pausar y despausar método (switch off/on)
    bool pausado; // = false;
    modifier protegerPausa() {
        // pausado es false, !pausado es true => continúa
        // pausado es true, !pausado es false => revierte, se interrumpe
        require(!pausado, "Metodo pausado");
        _;
    }

    function protegerMetodoConPausa() public protegerPausa {}

    function activarPausa() public onlyCaller {
        pausado = true;
    }

    function desactivarPausa() public onlyCaller {
        pausado = false;
    }

    // LISTA BLANCA
    //      address         |           bool
    //          0x1                     false
    //          0x2                     true
    //          0x3                     false
    //          0x4                     true
    mapping(address => bool) public listaPermitida;
    modifier validaListaBlanca() {
        // msg.sender: captura la persona que llama al metodo
        require(listaPermitida[msg.sender], "No estas autorizado");
        _;
    }

    function protegerMetodoPorListaBlanca() public validaListaBlanca {}

    function guardarEnListaBlanca(address _account) public onlyCaller {
        listaPermitida[_account] = true;
    }

    function sacarDeListaBlanca(address _account) public onlyCaller {
        listaPermitida[_account] = false;
    }
}
