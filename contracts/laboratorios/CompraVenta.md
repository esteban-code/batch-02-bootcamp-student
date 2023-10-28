# Contrato de compra y venta de Tokens (ERC20) usando monedas estables (e.g. USDC)

## Objetivos

1. Comprender qué es una moneda estable
2. Entender cómo la cantidad de decimales de un token tiene consencuencias a la hora de realizar transacciones
3. Desarrollar un contrato de compra de tokens (ERC20) usando un stable coin

## Desarrollo

### ¿Qué es una moneda estable (e.g. USDC)?

Están diseñadas para tener un valor estable que simula otro activo, como por ejemplo el dolar americano (u otras criptomonedas o comodities). El objetivo es proveer estabilidad y disminuir la volatilidad en el mundo de las criptomonedas. De esta manera se hace mucho más sencillo realizar transacciones porque el valor se vuelve muy predecible.

En específico, el USD Coin (USDC) o cripto dólar está vinculado con el dolar americano. Busca una paridad de 1 a 1. Es decir, que 1 USDC sería el equivalente de 1 USD. Sorprendentemente, este stable coin está respaldado por moneda fiat. Por cada USDC existente, existe 1 USD en fiat que lo respalda.

En el [explorador de bloques](https://polygonscan.com/token/0x2791bca1f2de4661ed88a30c99a7a9449aa84174?a=0x5a3d92e1ffabd2b04c911e46d1740a88d9358bde) podemos encontrar el token con una capitalización de más de más de 600 millones de USDC. Existen casi 2 millones de usuarios en todo el mundo. Un dato relevante como dinero programable es que tiene 6 decimales, lo cual tendremos en cuenta a la hora de ser intercambiado por otros tokens que poseen otra cantidad de decimales.

Para efectos de este ejercicio, vamos a publicar un clon del USDC. De ese modo simularemos la posesión de una cantidad de dólares cripto para realizar transacciones.

1. Realiza la publicación del siguiente contrato inteligente del USDC y guarda la dirección:

   ```solidity
   // SPDX-License-Identifier: MIT
   pragma solidity 0.8.19;
   
   import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
   
   contract USDCoin is ERC20 {
       constructor() ERC20("USD Coin", "USDC") {
           _mint(msg.sender, 1000000 * 10 ** decimals());
       }
   
       function mint(address to, uint256 amount) public {
           _mint(to, amount);
       }
   
       function decimals() public pure override returns (uint8) {
           return 6;
       }
   }
   ```

   Automáticamente, el que publica el contrato se hará acreedor de 1M de UDSCs. En realidad, cualquier persona que tenga un balance positivo podrá comprar otros activos digitales que utilicen USDC como moneda de intercambio. El address de este contrato es `0xDA0bab807633f07f013f94DD0E6A4F96F8742B53`. En tu caso será uno diferente.

### Desarrollo de un ERC20 para vender

El usuario tendrá que realizar una transferencia de USDC como requisito para acuñar nuevos tokens ERC20 a su favor. Este proceso de transferencia y acuñación tiene que ser programado y expuesto en un método público. Incluso otros contratos tendrían la capacidad de poder comprar tokens.

Empezemos con nuestro token ERC20. Usaremos el valor de decimales por defecto que es 18 para ver cómo intercambiarlo por un token que posee 6 decimales (USDC).

2. Este será el código de inicio de nuestro ERC20:

   ```solidity
   // SPDX-License-Identifier: MIT
   pragma solidity 0.8.19;
   
   import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
   import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
   
   contract MiTokenLeeMarreros is ERC20, ERC20Burnable {
       constructor() ERC20("Mi Token Lee Marreros", "MTLMRR") {}
   
       function mint(address to, uint256 amount) public {
           _mint(to, amount);
       }
   }
   ```

   Hasta ahora es un simple token que tiene una función pública `mint` y `burn` para acuñar y quemar respectivamente. Sin embargo, cualquier persona es libre de hacerlo sin ofrecer nada a cambio. Vamos a cambiar eso incluyendo una lógica de transferencia antes de hacer la acuñación.

3. Desarrollamos una interface del token UDSC para realizar una transferencia automática usando el `transferFrom` (que ya sabemos requiere previo permiso del usuario). Así también nos deshacemos del método `mint` público. Pasamos el address de `USDC` mediante el `constructor` y creamos una referencia del mismo contrato en `usdc`.

   ```solidity
   interface IUSDC {
       function transferFrom(
           address from,
           address to,
           uint256 amount
       ) external returns (bool);
   }
   
   contract MiTokenLeeMarreros is ERC20, ERC20Burnable {
       IUSDC usdc;
   
       uint256 public ratio = 50; // 1 USDC = 50 MTLMRR
   
       constructor(address usdcAddress) ERC20("Mi Token Lee Marreros", "MTLMRR") {
           usdc = IUSDC(usdcAddress);
       }
   }
   ```

4. Para poder hacer el intercambio de un token por otro necesitamos de un ratio de intercambio. Para este ejercicio lo definiremos en  `50` de manera fija. Es decir, `1 USDC equivale a 50 MTLMRR`. Este ratio puede ser actualizable con un setter que lo modifica a través del tiempo. Incluso, este ratio puede cambiar de manera dinámica (ver *bonding curves*).

3. Vale la pena hacer la aclaración que intercambiaremos un token de 6 decimales por otro que tiene 18 decimales y debemos tener ello en cuanto a la hora de hacer las matemáticas en nuestro método de compra.

   ```
   			  1 USDC = 50 MTLMRR
   1000000 (USDC) = 50000000000000000000 (MTLMRR)
   
   Nota la cantidad de ceros adicionales que se agregaron para mantener la equivalencia. En otras palabras, cada vez que nos envían una cantidad N de USDC, le agregamos 12 ceros adicionales para encontrar la equivalencia con nuestro token de 18 decimales.
   ```

4. Ahora vamos a definir dos métodos que nos ayudan con la compra. Imaginemos que vamos a comprar dólares a una casa de cambio. Hay dos maneras de hacerlo. O bien le decimos `"quiero comprar 100 dólares. ¿Cuánto de mi moneda tengo que darte?"`. O bien expresamos que `"tengo una cantidad X de mi moneda, ¿cuántos dólares me puedes dar?"`. En un escenario tengo una cantidad de dólares exactos que quiero recibir y en el otro poseo una cantidad exacta de mi moneda que quiero entregar. En código, son dos métodos diferentes. En el fondo, sin embargo, se usa el mismo ratio de cambio. Definamos esos métodos:

   ```solidity
   // Sé cuantos tokens MTLMRR deseo comprar
   // Calcula la cantidad de USDC a entregar
   function comprarTokensExactoPorUsdc(uint256 cantidadTokens) public {}
   
   // Sé cuantos USDC voy a entregar
   // Calcula la cantidad de tokens MTLMRR a recibir
   function comprarTokensPorUsdcExacto(uint256 cantidadDeUsdc) public {}
   ```

   Nota la sutil diferencia en donde se ubica la palabra `Exacto` en cada método.

5. Definamos con más detalle cada método:

   * En `comprarTokensExactoPorUsdc`,  `cantidadTokens` viene con `18` decimales, lo cual amerita quitarle `12` decimales para encontrar la cantidad de USDC a cobrar al usuario.
   * En `comprarTokensPorUsdcExacto`,  `cantidadDeUsdc` viene con `6` decimales, lo cual amerita agregarle `12` decimales para encontrar la cantidad de tokens `MTLMRR` a entregar al usuario.
   * A la interfaz de `IUSDC` se le agregó `decimals()` para que nos devuelva su cantidad de decimales. De ahí que se usa en `usdc.decimals()`. `decimals()` es parte del token `MTLMRR` y su valor es `18`.

   ```solidity
   function comprarTokensExactoPorUsdc(uint256 cantidadTokens) public {
       // cantidadTokens viene con 18 decimales
       uint256 amountUsdc = cantidadTokens / ratio;
   
       // le quitamos 12 decimales
       amountUsdc = amountUsdc / (10 ** (decimals() - usdc.decimals()));
   }
   
   function comprarTokensPorUsdcExacto(uint256 cantidadDeUsdc) public {
       // usdc viene con 6 decimales pero faltan 12
       uint256 cantidadTokens = cantidadDeUsdc * ratio;
   
       // agrega los 12 decimales
       // decimals() == 18
       // usdc.decimals() == 6
       cantidadTokens = cantidadTokens * 10 ** (decimals() - usdc.decimals());
   }
   ```

6. Antes de proceder con la transferencia de activos para cada uno de los métodos, vamos a añadir una firma más a la interfaz del `IUSDC` que es el `allowance`. Con este método evaluaremos si el contrato ya tiene el permiso suficiente para manipular los USDC del comprador. Este paso es opcional. Ello porque dentro del USDC, antes de ejecutar el  `transferFrom`, se hace la evaluación del `allowance`. Ahora haremos una repetición de ese chequeo para añadir un mensaje de validación amigable.

   ```solidity
   interface IUSDC {
       function transferFrom(
           address from,
           address to,
           uint256 amount
       ) external returns (bool);
   
       function decimals() external view returns (uint8);
   
       function allowance(address owner, address spender) external view returns (uint256);
   }
   ```

7. Dado que ambos métodos del punto `5` realizarán el mismo procedimiento, más vale aislar esa lógica en un método interno:

   ```solidity
   function _efectuarTransferYCompra(
       uint256 _cantidadDeUsdc,
       uint256 _cantidadTokens
   ) internal {
       uint256 _allowance = usdc.allowance(msg.sender, address(this));
       require(_allowance >= _cantidadDeUsdc, "Incorrecto permiso de USDC");
   
       usdc.transferFrom(msg.sender, address(this), _cantidadDeUsdc);
       _mint(msg.sender, _cantidadTokens);
   }
   ```

   * Hacemos una revisión del permiso otorgado por el comprador hacia el contrato.
   * El contrato es el que ejecuta el `transferFrom`. Por ello, el contrato se convierte en el `spender` o `gastador`.
   * Esta revisión del `allowance` es redundante porque dentro del contrato del USDC también se hace la misma revisión. Ahora solo queremos exponer un mensaje más amigable en el `require`. Nada más.
   * Superado el permiso, efectuamos dos tipos de transferencias. Una de USDC y otra del token `MTLMRR`.
   * Mediante `usdc.transferFrom`, se efectúa la transferencia de USDC del comprador (`msg.sender`) hacia el contrato (`address(this)`) en la cantidad de `_cantidadDeUsdc`.
   * Mediante `_mint(msg.sender, _cantidadTokens)`, se transfieren tokens `MTLMRR` en la cantidad de `_cantidadTokens` al comprador (`msg.sender`).
   * Ahora solo queda usar el método `_efectuarTransferYCompra`. Como nota, dentro de este mismo método podemos cobrar un impuesto por la compra si se desea. Ello disminuiría la cantidad de tokens `MTLMRR` acuñados para el usuario.

8. Así quedaría luego de incluir el método `_efectuarTransferYCompra`:

   ```solidity
   function comprarTokensExactoPorUsdc(uint256 cantidadTokens) public {
       // cantidadTokens viene con 18 decimales
       uint256 amountUsdc = cantidadTokens / ratio;
   
       // le quitamos 12 decimales
       amountUsdc = amountUsdc / (10 ** (decimals() - usdc.decimals()));
       _efectuarTransferYCompra(amountUsdc, cantidadTokens);
   }
   
   function comprarTokensPorUsdcExacto(uint256 cantidadDeUsdc) public {
       // usdc viene con 6 decimales pero faltan 12
       uint256 cantidadTokens = cantidadDeUsdc * ratio;
   
       // agrega los 12 decimales
       // decimals() == 18
       // usdc.decimals() == 6
       cantidadTokens = cantidadTokens * 10 ** (decimals() - usdc.decimals());
       _efectuarTransferYCompra(cantidadDeUsdc, cantidadTokens);
   }
   ```

9. Vamos a suponer que existe un método de devolución de tokens. Al hacerlo, el contrato `MiTokenLeeMarreros` te devuelve USDC. Para que esto funcione, los tokens `MTLMRR` deben ser quemados en primer lugar. En segundo lugar, se debería cobrar una comisión por devolución. Y finalmente, se debería calcular la cantidad de USDC a entregar al usuario como devolución. Veamos el método `burnTokensExacto`:

   ```solidity
   function burnTokensExacto(uint256 cantidadTokens) public {
       // cantidadTokens viene con 18 decimales
       // Se convierte a USDC con el ratio
       // Se cobra un fee del 10%
       uint256 usdcDevolver = cantidadTokens / 10 / ratio;
   
       // Se le quitan 12 decimales
       usdcDevolver = usdcDevolver / (10 ** (decimals() - usdc.decimals()));
   
       burn(cantidadTokens);
       // Efectúa la devolución de USDC al usuario
       usdc.transfer(msg.sender, usdcDevolver);
   }
   ```

   * Notar que para esto fue necesario agregar el método `transfer` a la interfaz del `IUSDC`.
   * Con `burn(cantidadTokens)` quemamos la cantidad de tokens `MTLMRR` que el usuario desea devolver.
   * Con `usdc.transfer(msg.sender, usdcDevolver)` es el mismo contrato que le devuelve USDC al usuario
   * Al momento de la devolución de USDC desde el contrato se puede hacer un chequeo si el contrato tiene el suficiente balance. Sin embargo, esa validación lo efectúa el mismo contrato USDC. Hacerlo aquí sería redundante.

10. Este sería el contrato final de `MiTokenLeeMarreros` que vamos a publicar:

    ```solidity
    // SPDX-License-Identifier: MIT
    pragma solidity 0.8.19;
    
    import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
    import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
    
    interface IUSDC {
        function transferFrom(
            address from,
            address to,
            uint256 amount
        ) external returns (bool);
    
        function decimals() external view returns (uint8);
    
        function allowance(
            address owner,
            address spender
        ) external view returns (uint256);
    
        function transfer(address to, uint256 amount) external returns (bool);
    }
    
    contract MiTokenLeeMarreros is ERC20, ERC20Burnable {
        IUSDC usdc;
    
        uint256 public ratio = 50; // 1 USDC = 50 MTLMRR
    
        constructor(address usdcAddress) ERC20("Mi Token Lee Marreros", "MTLMRR") {
            usdc = IUSDC(usdcAddress);
        }
    
        function comprarTokensExactoPorUsdc(uint256 cantidadTokens) public {
            // cantidadTokens viene con 18 decimales
            uint256 amountUsdc = cantidadTokens / ratio;
    
            // le quitamos 12 decimales
            amountUsdc = amountUsdc / (10 ** (decimals() - usdc.decimals()));
            _efectuarTransferYCompra(amountUsdc, cantidadTokens);
        }
    
        function comprarTokensPorUsdcExacto(uint256 cantidadDeUsdc) public {
            // usdc viene con 6 decimales pero faltan 12
            uint256 cantidadTokens = cantidadDeUsdc * ratio;
    
            // agrega los 12 decimales
            // decimals() == 18
            // usdc.decimals() == 6
            cantidadTokens = cantidadTokens * 10 ** (decimals() - usdc.decimals());
            _efectuarTransferYCompra(cantidadDeUsdc, cantidadTokens);
        }
    
        function _efectuarTransferYCompra(
            uint256 _cantidadDeUsdc,
            uint256 _cantidadTokens
        ) internal {
            uint256 _allowance = usdc.allowance(msg.sender, address(this));
            require(_allowance >= _cantidadDeUsdc, "Incorrecto permiso de USDC");
    
            usdc.transferFrom(msg.sender, address(this), _cantidadDeUsdc);
            _mint(msg.sender, _cantidadTokens);
        }
    
        function burnTokensExacto(uint256 cantidadTokens) public {
            // cantidadTokens viene con 18 decimales
            // Se convierte a USDC con el ratio
            // Se cobra un fee del 10%
            uint256 usdcDevolver = cantidadTokens / 10 / ratio;
    
            // Se le quitan 12 decimales
            usdcDevolver = usdcDevolver / (10 ** (decimals() - usdc.decimals()));
    
            burn(cantidadTokens);
    
            // Efectúa la devolución de USDC al usuario
            usdc.transfer(msg.sender, usdcDevolver);
        }
    }
    ```

    Su publicación require que se pase el address de `USDC` como argumento en el `constructor` de `MiTokenLeeMarreros`. Address de `MTLMRR`: `0x358AA13c52544ECCEF6B0ADD0f801012ADAD5eE3`.

### Comprando tokens `MTLMRR` con `USDC`

|               |                  Address                   |
| :-----------: | :----------------------------------------: |
|   **UDSC**    | 0xDA0bab807633f07f013f94DD0E6A4F96F8742B53 |
|  **MTLMRR**   | 0x358AA13c52544ECCEF6B0ADD0f801012ADAD5eE3 |
| **Comprador** | 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 |

Dado que tenemos un balance de USDC y el contrato del token `MTLMRR` publicado, procedemos a efectuar la compra:

11. El comprador debe dirigirse en primer lugar al contrato `USDC` para poder otorgar permiso al contrato del token `MTLMRR` de poder manejar sus dólares cripto antes de intentar hacer la compra de tokens  `MTLMRR`.

    ![image-20230925021108246](https://github.com/Blockchain-Bites/solidity-book/assets/3300958/6fc7aff6-3a42-4676-b8e0-3f9918958dbb)

    El comprador da un permiso de 1M de USDC al contrato del token `MTLMRR`.

12. Ahora me dirijo al contrato `MiTokenLeeMarreros` al método `comprarTokensPorUsdcExacto`. Voy a comprar con 100 USDC (más decimales) la cantidad de `MTLMRR` que alcance:

    ![image-20230925020125505](https://github.com/Blockchain-Bites/solidity-book/assets/3300958/a501193d-ef7a-4a70-bfb6-05be95da68a0)

13. Al revisar `balanceOf` del contrato `MiTokenLeeMarreros` obtenemos lo siguiente: `5000000000000000000000`. Lo cual equivale a 5000 tokens `MTLMRR` (más decimales).

    ![image-20230925021230857](https://github.com/Blockchain-Bites/solidity-book/assets/3300958/60de2bbe-94a7-4214-953b-dd44c555c22e)

14. Procedo a quemarlos con `burn` del contrato `MitokenLeeMarreros` para tener un balance cero previo a la siguiente compra. Ahora tengo un balance de 0 en token `MTLMRR`.

    ![image-20230925021509913](https://github.com/Blockchain-Bites/solidity-book/assets/3300958/e3fadb81-eaf5-4c9a-aa68-6d291447e4cc)

15. Ahora me dirijo al método `comprarTokensExactoPorUsdc` y le voy a pedir 4,500 tokens `MTLMRR`. Es decir, le voy a pedir `4500000000000000000000` si incluimos los decimales.

    ![image-20230925021649319](https://github.com/Blockchain-Bites/solidity-book/assets/3300958/5fba9eda-c2cc-43e2-8fd9-f012fc1f8a7d)

    Luego de efectuar esta compra podemos ver los siguientes eventos `Transfer`:

    ![image-20230925022132934](https://github.com/Blockchain-Bites/solidity-book/assets/3300958/c5b21ca1-7b79-4a6f-b71f-c58839a8e415)

    * El primer evento `Transfer` en `args` indica que que el address `0x5B38Da6a701c568545dCfcB03FcB875f56beddC4` (comprador) hizo una transferencia de `90000000` USDC al address `0x358AA13c52544ECCEF6B0ADD0f801012ADAD5eE3` (address del contrato `MTLMRR`). Este monto fue calculado dentro del método `comprarTokensExactoPorUsdc`.
    * El segundo evento `Transfer` indica una acuñación ya que el `from` en `args` es el address cero. Se acuñaron exactamente la cantidad de `4500000000000000000000` tokens `MTLMRR` a favor del comprador `0x5B38Da6a701c568545dCfcB03FcB875f56beddC4`.

16. Finalmente, vamos a hacer una devolución de `4500000000000000000000` utilizando el método de recompra del token `MTLMRR`.

    ![image-20230925022826745](https://github.com/Blockchain-Bites/solidity-book/assets/3300958/cf8c5b3e-93bc-4231-ae11-1a5ec1755ff3)

17. Este es el resultado:

    ![image-20230925022858764](https://github.com/Blockchain-Bites/solidity-book/assets/3300958/279b1007-acfb-4368-95a4-a9095bccc008)

    * El primer evento `Transfer` en `args` se muestra que el comprador transfirió sus tokens al address cero (un address sin llave privada). Es decir, quemó sus tokens.
    * A cambio, en el segundo evento `Transfer` (en `args`) se nota que el contrato del token `MTLMRR` transifirió `9000000` USDC al comprador. Cabe notar que `9000000` es el 10% de `90000000` USDC que fue lo que pagó para obtener `4500000000000000000000` tokens `MTLMRR`. Ello demuestra que se aplicó el impuesto del 10%.

## Tarea

1. Publica otro clon de USDC en `Mumbai` y pega el address aquí:

2. Publica un clon del contrato `MiTokenLeeMarreros` en `Mumbai`  teniendo en cuenta lo siguiente:

   * Usa tu propio nombre y símbolo

   * Incluye un impuesto del 30% a la compra. Es decir, si el usuario desea pagar 100 USDC, solo 70 UDSC será convertido a tu token. Si el usuario desea comprar 100 de tus token directamente, es porque el USDC que pagó fue 1.3 veces del valor sin impuesto

   * Desarrolla un mecanismo de lista negra. Es decir, si un address es incluido en esta lista, no podría comprar tus tokens. Este punto debe ser desarrollado usando el book  `_beforeTokenTransfer` definido en el papá:

     ```solidity
     function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
     ```

     Investiga. Sobreescribe este método desde el hijo para crear esa validación. Incluye la estructura de datos que necesites

3. Pega el address de tu contrato del token aquí: