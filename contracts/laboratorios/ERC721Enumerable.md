# ERC721 Enumerable: Enumeración de NFT

## Objetivos

- Conocer a alto nivel la extensión `ERC721Enumerable`
- Comprender el mecanismo de Enumerable en el Estándar ERC721

## Introducción

El estándar ERC721 ha sido fundamental en la plataforma Ethereum para la creación de tokens no fungibles (NFT). Sin embargo, los contratos ERC721 no ofrecen una forma eficiente de enumerar y explorar todos los NFTs dentro de un contrato ni una forma de saber qué NFTs posee una billetera. Para abordar esta limitación, se ha desarrollado la extensión `ERC721Enumerable` que añade tres funciones nuevas:

- `totalSupply()`: Devuelve el número total de tokens NFT emitidos por el contrato.
- `tokenByIndex()`: Devuelve el tokenId del NFT con el índice especificado.
- `tokenOfOwnerByIndex()`: Devuelve el tokenId del NFT con el address del owner y un índice en especifico.

Estas tres funciones permiten a los usuarios obtener una visión completa de todos los tokens NFT emitidos por un contrato y para una billetera puntual. Esto puede ser útil para aplicaciones que requieren la capacidad de buscar y filtrar tokens, como mercados de NFT o juegos.

## Desarrollo

### Creando un Contrato `ERC721Enumerable`

En lugar de comenzar desde cero, utilizaremos un contrato `ERC721Enumerable` básico para centrarnos en las funcionalidades específicas de la enumeración. A continuación, se muestra el contrato de ejemplo:

1. Abre Remix en tu navegador web.

2. Crea un nuevo archivo de contrato llamado `Enumerable.sol` y copia el siguiente código en el archivo `Enumerable.sol` 

   ```solidity
   // SPDX-License-Identifier: MIT
   pragma solidity 0.8.19;
   
   import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
   import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
   
   contract Enumerable is ERC721, ERC721Enumerable {
   
       constructor() ERC721("Enumerable", "ENMRBL") {}
   
       function _baseURI() internal pure override returns (string memory) {
           return "ipfs://Qma4s6uyVSCaTouXM8N8AkAL4jc11D53Tsn1kZPs4CGd6b/";
       }
   
       function safeMint(address to, uint256 tokenId) public {
           _safeMint(to, tokenId);
       }
   
       // The following functions are overrides required by Solidity.
   
       function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
           internal
           override(ERC721, ERC721Enumerable)
       {
           super._beforeTokenTransfer(from, to, tokenId, batchSize);
       }
   
       function supportsInterface(bytes4 interfaceId)
           public
           view
           override(ERC721, ERC721Enumerable)
           returns (bool)
       {
           return super.supportsInterface(interfaceId);
       }
   }
   ```

3. Compila, conecta tu billetera metamask con remix y despliega el contrato. 

   Acabas de compilar y desplegar un contrato que cumple con el estándar `ERC721` y aprovecha la extensión `ERC721Enumerable`. El contrato permitirá la emisión de NFTs únicos, cada uno identificado por un número de token único y asociado a una URI (ruta a la metadata en IPFS).

   Para este ejemplo cualquier cuanta puede acuñar NFTs. Dichos NFTs se podrán listar y explorar de manera eficiente utilizando las funcionalidades proporcionadas por `ERC721Enumerable`. 

   Al inspeccionar las funciones de lectura y escritura, notamos que hay tres nuevos métodos que éste trae y son los siguientes: `totalSupply` , `tokenByIndex`, `tokenOfOwnerByIndex`. Métodos que no formaban parte del `ERC721`.

   ![image-20230926070703826](https://github.com/Blockchain-Bites/solidity-book/assets/3300958/ec8c359f-6527-49c8-b2a0-08ffedf03fe8)

4. Ahora que el contrato está desplegado, puedes emitir un nuevo NFT. Haz clic en el contrato `Enumerable` en la sección `Deployed Contracts` de Remix. Desplázate hacia abajo hasta encontrar la función `safeMint`. Vamos a acuñar 4 NFTs a favor del que publica el contrato, a quien llamaremos `Propietario`. Utiliza los siguientes IDs para la acuñación: 10, 19, 3, 7.

### Enumeración de NFTs por Índice 

Ahora que hemos emitido varios NFTs, exploremos cómo enumerar y listar eficientemente estos NFTs dentro del contrato.

En el contexto de `ERC721Enumerable`,  `tokenByIndex` se refiere a una secuencia ordenada de todos los tokens no fungibles (NFTs) emitidos por el contrato. Cada NFT en esta lista se encuentra asociado a un índice numérico único que comienza en 0 y se incrementa en el orden de emisión. Esto implica que el primer NFT emitido tiene un índice de 0, el segundo tiene un índice de 1, el tercero tiene un índice de 2, y así sucesivamente. 

La función clave que facilita la interacción con esta lista es `tokenByIndex`. Esta función recibe un índice como parámetro y devuelve el `tokenId` del NFT que se encuentra en esa posición dentro de la lista. Para ilustrarlo mejor, consideremos el siguiente ejemplo:

Al consultar el método `tokenByIndex` con valores de índice desde 0 hasta 3, los resultados esperados serían los siguientes:

| tokenByIndex | Token ID |
| :----------: | :------: |
|      0       |    10    |
|      1       |    19    |
|      2       |    3     |
|      3       |    7     |

Usándo el método `tokenByIndex` ahora podemos obtener una lista completa de todos los token ID de los NFTs acuñados. Una vez obtenido el token ID, podemos realizar otras consultas usándolo como input de otros métodos de lectura. Para saber hasta dónde iterar con `tokenByIndex` para consultar los token IDs, podemos usar el `totalSupply` mencionado más abajo.

Adicional a ello, ahora también podemos obtener una lista de todos los token IDs que una billetera posee a través del método `tokenOfOwnerByIndex`. Veamos:

| method              | owner       | index | resultado |
| ------------------- | ----------- | ----- | --------- |
| tokenOfOwnerByIndex | Propietario | 0     | 10        |
| tokenOfOwnerByIndex | Propietario | 1     | 19        |
| tokenOfOwnerByIndex | Propietario | 2     | 3         |
| tokenOfOwnerByIndex | Propietario | 3     | 7         |

Es decir, ahora podemos consultar los token IDs que posee una billetera haciendo queries uno por uno. Y lo podemos hacer usando el índex (como parámetro de `tokenOfOwnerByIndex`) dado que éste va de manera secuencial empezando en cero. Para conocer hasta dónde iterar, podemos hacer uso del método `balanceOf(address)` que nos devolverá el total de NFTs de una billetera.

|  balanceOf  | resultado |
| :---------: | :-------: |
| Propietario |     4     |

Por ahora, aparentemente `tokenOfOwnerByIndex` y `tokenByIndex` parecen arrojar la misma información. Sin embargo, hay una sutil diferencia.

* `tokenByIndex` lista los NFTs acuñados por el contrato
* `tokenOfOwnerByIndex` lista los NFTs que fueron acuñados para una cuenta en particular

Esta diferencia será más evidente después de realizar dos transferencias de NFT.

### Obtener el Total de NFTs

Para conocer el número total de NFTs dentro del contrato, podemos utilizar la función `totalSupply` de ERC721 Enumerable. Esta función devuelve la cantidad total de NFTs emitidos por un contrato.

Selecciona la función `totalSupply`. Haz clic en `transact` para ejecutarla. Esta consulta debería retornar la cantidad total de NFTs emitidos, que en este caso debería ser 4 por las 4 veces que acuñaste los NFTs.

### Transfiere 2 NFTs 

Para profundizar  y comprender mejor cómo afecta la numeración con índices, realizaremos dos transferencias de NFTs. Estas transferencias son operaciones esenciales en los contratos ERC721, ya que posibilitan la transferencia de propiedad de un NFT de un `Propietario` a otro usuario `Destinatario`. Estas transferencias pueden tener un impacto significativo en la forma en que se enumeran y se acceden a los NFTs dentro del contrato. A continuación, llevaremos a cabo las siguientes transferencias utilizando el método `transferFrom`.

1. Transfiramos el NFT con `tokenId` 10 al `Destinatario`. Esto implica que el NFT con `tokenId` 10 ya no pertenece al `Propietario` y, en cambio, pasa a ser propiedad del `Destinatario`.

   ![image-20230926073808592](https://github.com/Blockchain-Bites/solidity-book/assets/3300958/56424a08-e28e-474d-88e4-e68a2069ca1a)

2. Realicemos la transferencia del NFT con `tokenId` 3 al `Destinatario`. De manera análoga, el NFT con `tokenId` 3 cambiará de propietario y será adquirido por el `Destinatario`.

   ![image-20230926073740285](https://github.com/Blockchain-Bites/solidity-book/assets/3300958/18fa5421-6b21-466b-aa2a-a4086f80c12e)

Verificaremos cómo ha cambiado la propiedad de los NFTs usando `ownerOf` en la siguiente tabla:

| ownerOf |    Owner     |
| :-----: | :----------: |
|   10    | Destinatario |
|   19    | Propietario  |
|    3    | Destinatario |
|    7    | Propietario  |

Aquí puedes observar claramente que los `tokenId` ahora están asociados a diferentes propietarios después de las transferencias. 

### Listar NFTs de un Propietario

Ahora, vamos a listar los NFTs del `Propietario` y `Destinatario` después de las transferencias utilizando la función `tokenOfOwnerByIndex`. Veamos la siguiente tabla:

|       method        |    owner     | index | resultado |
| :-----------------: | :----------: | :---: | :-------: |
| tokenOfOwnerByIndex | Propietario  |   0   |     7     |
| tokenOfOwnerByIndex | Propietario  |   1   |    19     |
| tokenOfOwnerByIndex | Destinatario |   0   |     3     |
| tokenOfOwnerByIndex | Destinatario |   1   |    10     |

* Antes el `Propietario` tenía más índices: 0, 1, 2 y 3. Ahora, luego de las transferencias, solo posee dos índices 0 y 1 que indican que solo posee 2 NFTs.
* Por otro lado, el `Destinatario` ahora tiene dos índices adicionales 0 y 1 que apuntan a sus dos nuevos NFTs. Antes no tenía ningún índice válido.
* Si consultamos `tokenByIndex` tendría que mantenerse del mismo modo. Ello porque `tokenByIndex` señala acuñaciones a nivel de contrato.
* En cambio, `tokenOfOwnerByIndex` señala las acuñaciones a nivel de billetera
* Para poder consultar todos los NFTs de una billetera, primero consultamos su balance de NFTs con el método `balanceOf(address)`.
* Luego de obtener este resultado, podemos usar el método `tokenOfOwnerByIndex` para iterar sobre cada índice y obtener su token ID asociado.

## Observaciones

1. El laboratorio demuestra cómo la extensión `ERC721Enumerable` mejora la capacidad de enumerar y gestionar tokens no fungibles (NFTs) en contratos ERC721, lo que es crucial para aplicaciones de mercado de NFTs y juegos.
2. Se destaca cómo las funciones como `totalSupply` y `tokenByIndex` facilitan la obtención de información sobre los NFTs emitidos y su posición en la lista, lo que es útil para la administración de NFTs.
3. La transferencia de NFTs entre propietarios afecta la lista que posee cada billetera que guarda en un array ordenado todos los token IDs que posee la misma.

## Preguntas

1. ¿Qué diferencias clave existen entre los estándares `ERC721` y `ERC721Enumerable` en términos de funcionalidad y usabilidad?
2. ¿Cómo se pueden utilizar las funciones `tokenOfOwnerByIndex` y `tokenByIndex` para enumerar y listar los NFTs de un propietario específico, y cuándo sería útil hacerlo en una aplicación?
3. ¿Cuáles son algunas posibles vulnerabilidades o desafíos en la gestión de NFTs en contratos inteligentes, y cómo se pueden abordar utilizando estándares como `ERC721Enumerable`?

## Tareas

1. Vuelve a publicar el contrato `Enumerable` y crea un método adicional que permite obtener el array de NFTs de una billetera usando como parámetro al `address`. 

2. Utiliza la siguiente firma y desarrolla su implementación:

   ```solidity
   function getNftsFromWallet(address account) public view returns(uint256[] memory result);
   ```

3. Publica el contrato en Mumbai y pega el `address` aquí:

4. Una billetera será el `Propietario` y otra `Destinatario`. `Propietario` debe acuñar 10 token IDs que son los siguientes: 2, 4, 6, 8, 10, 12, 14, 16, 18, 20. `Propietario` debe transferir a `Destinatario` los siguientes tokens: 4, 10, 14, 16 y 18.

5. El resultado esperado luego de llamar el método `getNftsFromWallet` es el siguiente:

   |    Address     |  getNftsFromWallet  |
   | :------------: | :-----------------: |
   | `Propietario`  |  [2, 6, 8, 12, 20]  |
   | `Destinatario` | [4, 10, 14, 16, 18] |