// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract A {
    /**
    'public'
    - es llamado por un EOA y SC
    - heredable
    - se usa internamente
    - ABI
    - sobreescribir (con virtual)
    */
    function funcHeredablePublicaEInterna() public virtual {}

    /**
    'internal'
    - heredar
    - se usa internamente
    - sobreescibir (con viritual)
    */
    function funcHeredableEInterna() internal virtual {}

    /**
    'private'
    - se usa internamente (en el mismo contrato)
    */
    function funcInterna() private {}

    /**
    'external'
    - llamado por EOA y SC
    - aparece en el ABI
    - heredable
    - sobreescribir
    */
    function funcExternaYHeredable() external virtual {}
}
