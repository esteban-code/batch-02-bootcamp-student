// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract EliminarLinearTime {
    uint256[] listaEnteros;

    constructor() {
        listaEnteros.push(6);
        listaEnteros.push(7);
        listaEnteros.push(9);
        listaEnteros.push(8);
        listaEnteros.push(10);
        listaEnteros.push(5);
        listaEnteros.push(2);
        listaEnteros.push(3);
        listaEnteros.push(1);
        listaEnteros.push(4);
    }

    function eliminarLinear(uint256 _el) public {
        uint256 i;
        for (i; i < listaEnteros.length; i++) {
            if (listaEnteros[i] == _el) break;
        }
        // Elemento a remover está en posición 'i'
        for (uint256 k = i + 1; k < listaEnteros.length; k++) {
            listaEnteros[i] = listaEnteros[k];
        }
        listaEnteros.pop();
    }

    function eliminarLinear2(uint256 _el) public {
        uint256 i;
        for (i; i < listaEnteros.length; i++) {
            if (listaEnteros[i] == _el) break;
        }
        listaEnteros[i] = listaEnteros[listaEnteros.length - 1];
        listaEnteros.pop();
    }

    function leerArray() public view returns (uint256[] memory) {
        return listaEnteros;
    }
}

contract EliminarKTime {
    uint256[] listaEnteros;
    mapping(uint256 entero => uint256 index) indexes;

    uint256 counter; // = 0

    function guardarEntero(uint256 _el) public {
        listaEnteros.push(_el);
        indexes[_el] = counter;
        counter++;
    }

    function eliminarEntero(uint256 _el) public {
        // lees el índex del elemento a eliminar
        uint256 ix = indexes[_el];

        // quitando del mapping al elemento a borrar
        delete indexes[_el];

        // lees el último elemento del array
        uint256 lastEl = listaEnteros[listaEnteros.length - 1];

        // duplicas el ultimo elemento en la posicion que quieres borrar
        listaEnteros[ix] = lastEl;

        // eliminar el último elemento del array
        listaEnteros.pop();

        // actualizar mapping del elemento movido
        indexes[lastEl] = ix;

        // decrementas el indice total (puntero)
        counter--;
    }

    function leerArray() public view returns (uint256[] memory) {
        return listaEnteros;
    }
}
