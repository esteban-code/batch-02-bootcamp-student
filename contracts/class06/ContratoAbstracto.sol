// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Contratos Abstractos
// - No define la implementación de alguno de sus métodos
// - Se delega la implemetanción a alguno de sus hijos
// - Se evita realizar la iniciacilación de su Constructor
// - Usar un método en el papá(pasado) y definirlo en el hijo (futuro)
// - No se puede publicar un contrato abstracto
// - Aseguran que los hijos implementen ciertas reglas (metodos) específicos

abstract contract UtilidadNeta {
    uint256 ingresosBrutos;
    uint256 gastosFijos;
    uint256 gastosVariables;
    uint256 impuestos;

    function calculoCostoTotal() public returns (uint256 utilidadNeta) {
        ingresosBrutos = calculoIngresosBrutos();
        gastosFijos = calculoGastosFijos();
        gastosVariables = calculoGastosVariables();
        impuestos = calculoImpuestos(ingresosBrutos);

        utilidadNeta =
            ingresosBrutos -
            (gastosFijos - gastosVariables) -
            impuestos;
    }

    function calculoIngresosBrutos() public returns (uint256) {
        // otras operaciones
    }

    function calculoGastosFijos() public returns (uint256) {
        // otras operaciones
    }

    function calculoGastosVariables() public returns (uint256) {
        // otras operaciones
    }

    function calculoImpuestos(
        uint256 _ingresos
    ) public virtual returns (uint256);
}

contract Empresa10PorCiento is UtilidadNeta {
    uint256 taxPercentage = 10; // 10 puntos porcentuales

    function calculoImpuestos(
        uint256 _ingresos
    ) public view override returns (uint256) {
        return (_ingresos * taxPercentage) / 100;
    }
}
