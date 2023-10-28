// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract MiPrimerContrato {
    ////////////////////////////////////////////
    /// Storage: 
    /// - todas las variables fuera de los métodos
    /// - Guardar en memoria permanente                                      ///
    ///                                      ///
    ////////////////////////////////////////////

    // Solidity es un lenguaje tipado
    
    // uint256
    // uint: usigned integer = entero sin signo
    // 256: es el rango de enteros
    // Rango: [0 - 2^256 - 1]
    uint256 edad = 99;

    // uint128
    // Rango: [0 - 2^128 - 1]
    uint128 anio = 2023;

    // uint64, uint32, uint16

    // Entero con signo
    // int256
    // Rango: [- 2^256 - 2^256 - 1]
    int256 enteroConSigno = -300;

    // setters y getter
    // setter: es una manera de actualizar información
    // getter: una manera de leer información

    // Setter
    // Cuando se define un método, se define también la VISIBILIDAD del método
    // Visibilidades del método: public, private, internal, external, pure, view
    // public:
    // - significa que dicho metodo puede ser usado desde afuera
    // - significa que dicho metodo puede ser usando dentro del contrato inteligente
    // - significa que puede heredarse
    function actualizarEdad(uint256 nuevaEdad) public {
        edad = nuevaEdad;
    }

    // Getter
    // Métodos de lectura: se agrega la visibilidad 'view'
    // No se usa 'this' como lo usarias en JS o Java
    // this: se usa dentro del contrato y funciona como si fuera una llamada 'external'
    function leerEdad() public view returns(uint256) {
        return edad;
    }

    // INICIALIZACION DE VARIABLES EN SOLIDITY
    // En Solidity TODAS las variables se inicializan por defecto
    // Se inicializan dependiendo su tipo de dato
    // Si es uint256 se inicializa con 0
    // Si es bool se inicializa con false
    // Si es string se inicializa con ""
    // address es el tipo de dato de la billetera
    address miBilletera =              0xCA420CC41ccF5499c05AB3C0B771CE780198555e;
    // Si es address se inicializa con 0x0000000000000000000000000000000000000000;
    uint256 edadSinInicializar;
    function leerEdadSininicializar() public view returns(uint256) {
        return edadSinInicializar;
    }

    // selfdestruct

    // Setter
    // Usando un metodo setter y se llama a un metodo view
    // Un metodo view paga gas cuando se llama desde un metodo setter
    function cambiarEdad() public {
        // edadSinInicializar = 100;
        edadSinInicializar = leerEdadSininicializar();
    }

    // public en variable
    // si se añade 'public' a una varible, se le crea un getter automaticamente
    // El getter creado con 'public' tiene una visibilidad de view (solo lectura)
    // el getter mes() no se puede usar dentro de otro metodo en el contrato
    // El objetivo es que sea consumido por fuera del contrato (no adentro)
    // storage: todo lo que esta fuera de las funciones
    uint256 public mes = 9;
    // uint256 private mes2 = 9;
    // getter: para leer info
    // function leerMes() public view returns(uint256) {
    //     return mes;
    // }
}