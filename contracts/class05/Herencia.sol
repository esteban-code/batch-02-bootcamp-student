// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract A {

} // A: contrato base. Papa

contract B is A {

} // is signfica que hereda otro contrato. B: contrato derivado. Hijo

contract C {

} // contrato base

contract D {

} // contrato base

contract E is C, D {

} // contrato derivado. Tiene dos papas: C y D. Múltiple herencia es posible

// Orden de herencia de contrato
// Algoritmo C3 Linearization
contract Humano {

} // más base

contract Hombre is Humano {}

// contract Marcos is Hombre, Humano {} INCORRECTO
// Se heredan los contratos desde el más BASE hasta el más DERIVADO
//              MAS BASE => MAS DERIVADO
contract Marcos is Humano, Hombre {

}

// Elementos de un contrato se heredan
contract Padre {
    // variables de estado
    // metodos
    // modifiers
    // eventos
}

contract Hijo is Padre {}
