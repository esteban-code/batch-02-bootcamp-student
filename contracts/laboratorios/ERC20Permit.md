# ERC20Permit: Aprobaciones sin gas mediante firmas

## Objetivos

- Conocer a alto nivel la extensión `ERC20Permit`
- Aprender a realizar transacciones de aprobación sin gas entre dos usuarios
- Comprender el mecanismo de firmas que permite las aprobaciones sin gas

## Introducción

El estándar `ERC20Permit` remplaza al método `approve` del estándar ERC20. La diferencia radica en que el `Propietario` de los tokens, quien es aquel que otorga el `allowance`, no es el que paga dicha transacción, la delega.

El `Propietario` de los tokens creará una firma figital que representa su intención de otorgar `allowance`. Dicha firma es generada fuera del Blockchain (off-chain) y, por tanto, no acarrea costos. El `Propietario` es el único que puede generar esta firma digital dado que su creación implica usar su llave privada.

Dentro de esta firma digital se incluyen ciertos parámetros de la intención del `Propietario`. Podemos encontrar los siguiente elementos:

- Address del `Propietario`
- Address del `Gastador`
- Cantidad a dar permiso
- Address del token (el mismo que implementa el `ERC20Permit`)
- Fecha de expiración de la intención
- Conteo de permisos otorgados hasta el momento (`nonce`)

Son estos mismos parámetros que ayudan a proteger al `Propietario` de malos usos que se pueda dar a su firma digital.

Una vez generada la firma digital, ésta es ejecutada dentro del método `permit()` de un contrato que implementa el `ERC20Permit`. Y lo interesante es que cualquier persona (con balance de gas) puede ejecutar la intención del propietario para que sea grabado on-chain.

Luego de efectuar el método `permit()`, se puede verificar dicho permiso usando el método `allowance`, del mismo modo que lo harías en un contrato `ERC20`. Es decir, encontraremos que un `Gastador` ahora tiene el permiso de manejar los tokens de el `Propietario`. ¡Y sin usar el método `approve()` por parte del `Propietario` de los tokens!

Veámoslo gráficamente:

![image-20230909205530920](https://github.com/Blockchain-Bites/solidity-book/assets/3300958/9d7de0fb-8460-4a8e-85a6-735f51b55a07)

1. El `Propietario` genera la firma off-chain
2. Dicha firma es enviada a cualquier persona (`X`) con balance para pagar la transacción
3. Se llama al método `permit()` del `ERC20Permit` usando la firma y otros parámetros
4. El efecto neto es que un `Gastador` recibe `allowance` de un `Propietario`

## Desarrollo

### Creación del contrato que implementa `ERC20Permit`

1. Nos dirigmos a [Remix](https://remix.ethereum.org/) y creamos un contrato que se llame `Token20Permit.sol`. El objetivo es lograr la creación de un token `ERC20` que permita llamar a su método `approve` usando firmas off-chain.

2. Dentro de ese archivo pegamos el siguiente código:

   ```solidity
   // SPDX-License-Identifier: MIT
   pragma solidity 0.8.19;

   import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
   import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

   contract Token20Permit is ERC20, ERC20Permit {
       constructor()
           ERC20("Token20 Permit", "TKN20PER")
           ERC20Permit("Token20 Permit")
       {
           _mint(msg.sender, 1000 * 10 ** decimals());
       }
   }
   ```

   Nota que estamos creando un nuevo token llamado `Token20 Permit` con el símbolo de `TKN20PER`. En esta ocasión, este token hereda el `ERC20` y uno adicional llamado `ERC20Permit`.

   Al inspeccionar el `ERC20Permit`, notamos que hay tres nuevos métodos que éste trae y son los siguientes:

   ```solidity
   function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external
   function nonces(address owner) external view returns (uint)
   function DOMAIN_SEPARATOR() external view returns (bytes32)
   ```

3. Serán esos mismos métodos adicionales del `ERC20Permit` que nos permitirá crear firmas. Expliquemos brevemente cada uno:

   - `permit()`: este método es el que finalmente altera el mapping de `allowances`. El punto de partida son los parámetros definidos por el `Propietario` que son los siguientes: `owner`, `spender`, `value` y `deadline`. Así también, el `Propietario` crea la firma digital descompuesta en `v`, `r`, y `s`, lo cual veremos cómo se genera más adelante.
   - `nonces()`: es la cantidad de permisos otorgados de aquel que generó la firma. Se usa como técnica para evitar el replay attack (o ataque de repetición). Internamente se lleva dicha cuenta y se incrementa cada vez que el método `permit` se ejecuta por un `Propietario` en particular.
   - `DOMAIN_SEPARATOR()`: Este método es definido de acuerdo al [`EIP712`](https://eips.ethereum.org/EIPS/eip-712). El objetivo es crear un dominio único de aplicación para el token que usará el `ERC20Permit`. De ese modo la firma digital será valida únicamente en este contrato (y no en otro que también implementa `ERC20Permit`).

4. Antes de continuar, voy a preparar tres billeteras (o addresses): el `Propietario` de los tokens, el `Gastador` y una billetera `X` que será el que ejecuta el `permit()`. En mi caso son las siguientes (en tu caso serán otros valores):

   |                 |                  Address                   |
   | :-------------: | :----------------------------------------: |
   | **Propietario** | 0xCA420CC41ccF5499c05AB3C0B771CE780198555e |
   |  **Gastador**   | 0x08Fb288FcC281969A0BBE6773857F99360f2Ca06 |
   |      **X**      | 0xF90a9359f2422b6885c900091f2aCc93E0933B7a |

   De estas tres mencionadas, solo la billetera `X` es la que requiere tener un balance positivo de gas (o MATIC en la red de Mumbai) para poder pagar la transaccción. El `Propietario` generará la firma off-chain, que no involucra gastos. El `allowance` del `Gastador` será modificado dentro del método `permit()` que es llamado por `X`.

5. Vamos a publicar este contrato en la red de `Mumbai`.

   - En `Metamask` me conecto en la red `Mumbai`
   - En `Metamask` me cambio a la cuenta del `Propietario`. Corroboro en `Remix` en la sección `ACCOUNT`.
   - Al momento de publicar el contrato se acuñarán a su favor 1000 (seguido de 18 ceros) tokens `TKN20PER`. Este propietario será el mismo que creará la firma digital off-chain usando su llave privada
   - En `Remix` , dentro de `ENVIRONMENT`, cambio a `Injected Provider - Metamask`
   - Abro mi archivo `Token20Permit.sol` y le doy click en `Deploy`. El address de mi contrato publicado en la red de `Mumbai` es `0xea7f87FD4Ca9F5007E3C5e59089b3c88787d5eE3`. Tu address será diferente a la mía.

### Generación de la firma off-chain

1. Generar la firma off-chain (fuera del blockchain) implica cierta complejidad. Para enfocarnos en lo más importante, he creado un archivo (`./scripts/erc20Permit.js`) que abstrae la generación de firmas off-chain. Puedes revisarlo detenidamente para comprender su funcionamiento y seguir los anotaciones. Estamos usando la librería `Hardhat`. El resultado es un script que se ejecutará dentro del contexto de `Hardhat`, como le veremos más adelante.

2. En el archivo `./scripts/erc20Permit.js`, hay dos variables que vas a modificar: `tokenAddress` y `spenderAddress`. En mi caso en particular lo reemplazo de este modo:

   ```javascript
   ////////////////////////// VARIABLES A CAMBIAR ///////////////////////
   // Address del contrato que implementa ERC20Permit de Remix
   const tokenAddress = "0xea7f87FD4Ca9F5007E3C5e59089b3c88787d5eE3";
   // Address del Gastador que recibirá el allowance del Propietario
   const spenderAddress = "0x08Fb288FcC281969A0BBE6773857F99360f2Ca06";
   //////////////////////////////////////////////////////////////////////
   ```

   `tokenAddress` es el address que obtuve en el paso 5. `spenderAddress` es el `Gastador` del paso 4.

3. Este script será ejecutado dentro del contexto de `Hardhat`. Como tal, el script usará información del archivo `hardhat.config.js` y es importante que tengas configurado tanto el `url` como los `accounts` dentro de la red `mumbai`. Esto involucra tener preparado un archivo `.env` con al menos dos claves:

   ```
   MUMBAI_TESNET_URL=
   PRIVATE_KEY=
   ```

   Cuando se genera la firma con `Hardhat` se usará la llave privada (`PRIVATE_KEY`) del archivo `.env`. Es por ello que la llave privada (`PRIVATE_KEY`) de `.env` tiene que ser del `Propietario` que tiene el address `0xCA420CC41ccF5499c05AB3C0B771CE780198555e`. En tu caso el `Propietario` tendrá otro valor que tú hayas definido.

   En `hardhat.config.js` debería tener el valor de `accounts` del siguiente modo:

   ```javascript
   accounts: [process.env.PRIVATE_KEY],
   ```

   Dicho valor será usado en el script del `erc20Permit.js`:

   ```javascript
   const [owner] = await ethers.getSigners();
   const ownerAddress = await owner.getAddress();
   ```

   Aquí, `owner` es el mismo del array `accounts`.

4. Corremos el siguiente comando en el terminal (recomendación usa node 16.x):

   ```bash
   npx hardhat --network mumbai run scripts/erc20Permit.js
   ```

   El resultado que obtuve es el siguiente:

   ```
   ownerAddress: 0xCA420CC41ccF5499c05AB3C0B771CE780198555e
   spenderAddress: 0x08Fb288FcC281969A0BBE6773857F99360f2Ca06
   value: 1000000000000000000000
   deadline: 1694400924
   v: 27
   r: 0x93fddcf9306e3590ac78d2a05642676e0958c789143d8c3603fdd259d9544bb6
   s: 0x032c2f8ebe0f2f30f3e6c7342bc727fdeae6ff5105d5e6060e126061e2b8ba6f
   Address recuperada de firma: 0xCA420CC41ccF5499c05AB3C0B771CE780198555e
   ```

5. Vamos a necesitar los siete (7) valores iniciales para llamar al método `permit()` del contrato inteligente.

   | Concepto       | Valores                                                            |
   | -------------- | ------------------------------------------------------------------ |
   | ownerAddress   | 0xCA420CC41ccF5499c05AB3C0B771CE780198555e                         |
   | spenderAddress | 0x08Fb288FcC281969A0BBE6773857F99360f2Ca06                         |
   | value          | 1000000000000000000000                                             |
   | deadline       | 1694400924                                                         |
   | v              | 27                                                                 |
   | r              | 0x93fddcf9306e3590ac78d2a05642676e0958c789143d8c3603fdd259d9544bb6 |
   | s              | 0x032c2f8ebe0f2f30f3e6c7342bc727fdeae6ff5105d5e6060e126061e2b8ba6f |

   - El `ownerAddress` está firmando que le otorga un permiso a `spenderAddress`
   - La cantidad de `allowance` codificada en la firma es 1000 tokens (seguido de 18 decimales)
   - El `deadline` en este script está marcado para después de 10 minutos. Si se intenta usar esta firma pasado el `deadline`, la transacción fallará
   - `v`, `r` y `s` son los componentes de la firma digital que se volverán a verificar en el contrato inteligente

   Una vez que tenemos estos valores, podemos pasárselo a cualquier (`X`) para que pueda pasar la intención del `Propietario` a una transacción on-chain y se modifique el mapping de `allowances`.

## Ejecutando la firma en el contrato `ERC20Permit`

1. Abrimos `Metamask` y cambiamos a la cuenta del `X`: `0xF90a9359f2422b6885c900091f2aCc93E0933B7a`. Esta address será la que firmará esta transacción. En tu caso tendrás otro valor.

2. Hacemos click en el ícono `Deploy & run transactions`. Corroboro que en `Remix` el `ACCOUNT` sea el de `X`. Esta es la única cuenta que necesita tener un balance de `MATIC` para pagar la transacción.

3. Buscamos el método `permit()` (de color amarillo) en la columna izquierda: posee 7 argumentos: `owner`, `spender`, `value`, `deadline`, `v`, `r` y `s`. Insertamos los valores de la tabla del paso 5 (tus valores serán diferentes). Hacemos click en `transact` y firmamos con la billetera de `X`.

   ![image-20230910222149865](https://github.com/Blockchain-Bites/solidity-book/assets/3300958/c4f202ac-83ff-4be2-a92d-b7d6f4b30861)

4. Finalizada la transacción, corroboramos que el `allowance` se le haya otorgado del `Propietario` al `Gastador`. Nos dirigimos al método `allowance()` (de color azul). Insertamos los valores `owner` (`0xCA420CC41ccF5499c05AB3C0B771CE780198555e`) y `spender` (`0x08Fb288FcC281969A0BBE6773857F99360f2Ca06`). Tus valores serán diferentes. Eso quiere decir que el `Gastador` ahora puede manipular los tokens del `Propietario` en dicha cantidad mostrada.

   ![image-20230910222132508](https://github.com/Blockchain-Bites/solidity-book/assets/3300958/462a9775-0aff-4153-9ac5-f600206e9d6a)

5. A partir de aquí el `Gastador` puede ejecutar el método `transferFrom()` siguiendo el estándar `ERC20`.

Si lograste este resultado, felicidades. Haz realizado con éxitos este laboratorio.

## Observaciones

1. La billetera `X` puede ser reemplazada por cualquier otra que tenga balance de `MATIC` para pagar la transacción. Incluso, el mismo `Gastador` puede ser `X` también.
2. `X` es indistinto si es un EOA o SCA. El papel de `X` es que ejecute el método `permit()`. El gastador, que en el ejemplo es `Bob`, puede ser reemplazado por un contrato inteligente. En ese caso, un SCA se convertiría en el gastador. Este gastador puede ejecutar `transferFrom()` según su lógica en el futuro.

## Preguntas

1. ¿En qué situaciones consideras que es beneficioso para el dueño de los tokens obviar el pago por transferencia de tokens?
2. ¿Logras identificar algunos vectores de ataque? ¿Indaga cómo [`EPI712`](https://eips.ethereum.org/EIPS/eip-712) y [`ERC2612`](https://eips.ethereum.org/EIPS/eip-2612) alivian potenciales vulnerabilidades?

## Tarea

1. Publica otro token similar a `Token20Permit` con tu propio nombre (seguido de la palabra `permi`) y símbolo. Pega el address aquí:
2. Como `Propietario` genera una firma off-chain. Utiliza una address que represente a `X` y utiliza la firma off-chain para ejecutar el método `permit`. Pega el hash de la transacción aquí:
