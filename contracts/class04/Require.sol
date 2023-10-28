// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// error AddressZero();

contract Require {
    // | ------------- | -------- | ------ | ---------- | --------- |
    // |   address     | Historia | Lengua | Matematica | Geografia | <- string
    // | Juan (0x01)   | 20       | 20     | 20         | 20        |
    // | Maria (0x02)  | 20       | 20     | 20         | 20        | <- uint256
    // | Carlos (0x03) | 20       | 20     | 20         | 20        |
    // | Sara (0x04)   | 20       | 20     | 20         | 20        |

    /**
     * Vamos a validar los siguientes casos:
     *
     * GUARDAR NOTA:
     * - 1G - La nota tiene que ser mayor o igual a 0 pero menor o igual a 20
     * - 2G - El address del alumno no puede ser el address 0: 0x0000000000000000000000000000000000000000
     * - 3G - La materia no puede ser un string vacío
     *
     * BORRAR NOTA:
     * - 1B - El address del alumno no puede ser el address 0: 0x0000000000000000000000000000000000000000
     */

    /**
    REQUIRE

    - require(validacion logica, mensaje si falla la validacion logica)
    - Validacion logica: 
        - podemos usar cualquier boolean
        - >, >=, ==, <, <=
        - &, ||
        nota > 0 & nota <= 20: resultado de esto es un bool
    - Revierten todos los cambios (atomicidad de la transacción)
    - Las validaciones de inputs se deben hacer bien al inicio
    - El usuario paga (gas) por la tx hasta que se llegue a un require
    - Un require dispara al reversión de todos los cambios
    - Patron para plantear opearciones en un metodo: Checks, effects, interaction
        - checks: validaciones
        - effects: actualizciones en las variables
        - interaction: comunicacion con otros contratos inteligentes
        * Este patrón previene la vulnerabilidad más conocida llamada REENTRANCY ATTACK
    */
    mapping(address alumno => mapping(string materia => uint256 nota))
        public notasPorAlumno;

    function guardarNotaParaAlumno(
        address alumno,
        string memory materia,
        uint256 nota
    ) public {
        // nota > 0 & nota <= 20
        // validación de input porque estoy validando los parámetros del métodos
        // require(validacion logica, mensaje de error);
        require(nota >= 0 && nota <= 20, "Nota fuera de rango");

        // address(0) = 0x000000.....000
        // No existe en el mundo una persona que tenga la llave privada del Address Zero
        require(alumno != address(0), "Address Zero");

        // Validar que materia no sea un string vacio
        //  str != "" (Javascript)
        // bytes(materia).length: se convierte a bytes y luego calculas su longitud (cuantos bytes está usando)
        // !bytes(materia).length - casting
        // require(!bytes(materia).length, "Materia esta vacia"); NO HAY CASTING DE ESE MODO EN SOlidity
        require(bytes(materia).length > 0, "Materia esta vacia");

        notasPorAlumno[alumno][materia] = nota;
    }

    // REVERT
    // - Es otra manera de hacer validaciones en SOLIDiITY
    // - sintaxis: revert(mensaje de error a propagar)
    // - La lógica de validación está fuera del revert
    // - La lógica de validación lo hace el programador fuera del revert

    // Error Personalizado
    // Este tipo de error es menos costoso en gas
    // El error y el mensaje son uno solo (vs en require hay error y msg separados)
    error AddressZero();

    // Error personalizado para validacion de nota
    error NotaIncorrecta(uint256 notaIncorrecta);

    function guardarNotaParaAlumnoRevert(
        address alumno,
        string memory materia,
        uint256 nota
    ) public {
        // nota > 0 & nota <= 20
        if (nota < 0 || nota > 20) {
            if (nota < 0 || nota > 20) {
                if (nota < 0 || nota > 20) {
                    revert NotaIncorrecta(nota);
                    // revert("Nota fuera de rango");
                }
            }
        }

        // alumno no sea address(0)
        if (alumno == address(0)) {
            revert AddressZero();
        }

        // Validar que materia no sea un string vacio
        notasPorAlumno[alumno][materia] = nota;
        // ... OTRAS OPERACIONES COMPLEJAS

        // assert
        // Tipo de validación especial y FUERTE
        // Sirve para validar INVARIANTES
        // Qué es un INVARIANTE
        // - Es algo que nunca debe cambiar/ siempre debe estar dentro un rango
        // - Si cambia/o sale fuera de rango => señal de fallas en la lógica => BUG TERRIBLE!!!!!!!!!
        // Ejemplo de invariantes:
        // - balance es negativo
        // - total supply es negativo
        // - precio es negativo
        // - edad esta por encima de los 200 años (require)
        // Es raro usar asserts para validar todo. Seria un overkill
        // Por lo general se usa los requires
        // Usar luego de hacer calculos que consideres complejos
        // Sintaxis: assert(validacion logica);
        //      - la validacion logica si es true, el assert no se dispara (no se interrumpe la op.)
        //      - la validacion logica si es false, se interrumpe, se revierten los cambios, tx falla

        // Static Analysis se aplica direcatmente a los assert
        assert(notasPorAlumno[alumno][materia] == nota);
    }
}

contract Require2 {
    // Aquí también puedo usar AddressZero();
}
