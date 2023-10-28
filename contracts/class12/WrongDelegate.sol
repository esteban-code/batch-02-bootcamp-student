// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract A {
    /**
        A: Es el que hace el delegate call
        - ¿Que pasa si A hace un delegateCall a B y luego a C?
            Rpta.: B y C tienen el mismo plano de memoria. No habria problemas
        
        - ¿Que pasa si A hace un delegateCall a B y luego a Incompatible?
            Rpta.: B e Incompatible tienen planos diferentes y podría generar colisiones
        
        CONCLUSIÓN:
        Cuando se hace delegateCalls a diferentes contratos, éstos deben tener
        los mismos planos de memoria (storage layout). De lo contrario tendrás
        colisiones, reemplazos indeseados.

        En el caso del contrato Compatible se mantiene el plano de A, B y C
        porque se duplican las variables ya utilizadas. Después de las variables
        utilizadas se pueden añadir nuevas variables.
    */
}

contract B {
    uint256 year = 2023;
    bool acceso = true;
}

contract C {
    uint256 year = 2023;
    bool acceso = true;
}

contract Incompatible {
    mapping(address => bool) listaBlanca;
    uint256[] list = [uint256(1), 2, 3, 4, 5];
}

contract Compatible {
    uint256 year = 2023;
    bool acceso = true;
    mapping(address => bool) listaBlanca;
    uint256[] list = [uint256(1), 2, 3, 4, 5];
}
