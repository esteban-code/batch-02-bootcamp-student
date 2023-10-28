// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Struct {
    // Te permite crear tipos de datos complejos definidos por el usuario
    // Es como una variable que agrupa a otro conjunto de variables
    struct Balance {
        uint256 monto;
        uint256 limiteGasto;
        uint256 interes;
        string nombre;
    }

    // Inicializar un struct
    // Versión corta de definición struct
    // No es la más legible
    function crearBalance() public {
        Balance memory miBalance = Balance(123, 1000, 200, "Cuenta de Ahorro");
    }

    function crearBalanceLegible() public {
        Balance memory miBalance = Balance({
            limiteGasto: 1000,
            interes: 200,
            nombre: "Cuenta de Ahorro",
            monto: 123
        });
    }
}

contract StructYMapping {
    struct Profesor {
        string nombre;
        string curso;
        uint256 edad;
        string ubicacion;
    }

    mapping(address => Profesor) public profesores;
    Profesor[] arrayProfesores;

    // setter
    function guardarInfoProfesor(
        string memory _nombre,
        string memory _curso,
        uint256 _edad,
        string memory _ubicacion,
        address _account
    ) public {
        Profesor memory profesor = Profesor({
            nombre: _nombre,
            curso: _curso,
            edad: _edad,
            ubicacion: _ubicacion
        });

        profesores[_account] = profesor;
        arrayProfesores.push(profesor);
    }
}

contract StructMappingAnidado {
    struct DNI {
        uint256 number;
        string nombre;
        string apellido;
    }
    struct Persona {
        DNI dni;
        uint256 altura;
        uint256 peso;
        mapping(string tipoDeActivo => uint256 cantidad) listaDeActivos;
    }

    mapping(address => Persona) public listaPersonas;

    // Setter para mapping listaPersonas
    function guardarPersona(address _personaAddress) public {
        DNI memory _dni = DNI(12341234, "Lee", "M");
        // Persona memory _persona = Persona({
        //     dni: _dni,
        //     altura: 166,
        //     peso: 80,
        //     // defino mi mapping: NO SE PUEDE
        // });

        // //          address             |           Persona
        // //          _personaAddress                 _persona
        // listaPersonas[_personaAddress] = _persona; // guardar en la tabla (de manera permanente)

        // Para acceder a la columan de la derecha hacemos:
        // Todo lo que pasa por memory: es duplicar la información
        // Todo lo que pasa por storage: es crear una referencia (puntero). No se hace una copia
        Persona storage _persona = listaPersonas[_personaAddress];
        _persona.dni = _dni;
        _persona.altura = 166;
        _persona.peso = 80;
        _persona.listaDeActivos["Casa"] = 100;
        _persona.listaDeActivos["Carros"] = 200;
        _persona.listaDeActivos["Avio"] = 130;
    }

    // function leerPersona(address _personaAddress) public {
    //     Persona memory _persona = listaPersonas[_personaAddress]; // leyendo la segunda columna (_persona)
    // }

    mapping(address => uint256) public billeteraAEdad;
}
