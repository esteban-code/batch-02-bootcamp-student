# Cross-chain Operations

Vamos a desarrollar un mecanismo de Airdrop cross-chain. El contrato para participar en Airdrop será publicado en Mumbai. Los tokens del Airdrop se entregan en Sepolia.

## Contrato Airdrop en Mumbai

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract AirdropOneCrossChain is Pausable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    uint256 public constant totalAirdropMax = 10 ** 6 * 10 ** 18;
    uint256 public constant quemaTokensParticipar = 10 * 10 ** 18;

    uint256 airdropGivenSoFar;

    mapping(address => bool) public whiteList;
    mapping(address => bool) public haSolicitado;

    event MintInAnotherChain(address account, uint256 tokens);
    event BurnCrossChain(address account, uint256 tokens);

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
    }

    function participateInAirdrop() public whenNotPaused {
        // pedir numero random de tokens
        uint256 tokensToReceive = _getRadomNumberBelow1000();

        // verificar que no se exceda el total de tokens a repartir
        require(
            airdropGivenSoFar + tokensToReceive <= totalAirdropMax,
            "No hay tokens disponibles"
        );

        // actualizar el conteo de tokens repartidos
        airdropGivenSoFar += tokensToReceive;
        // marcar que ya ha participado
        haSolicitado[msg.sender] = true;

        // emitir evento de transferencia
        emit MintInAnotherChain(msg.sender, tokensToReceive);
    }

    function quemarMisTokensParaParticipar() public whenNotPaused {
        // verificar que el usuario aun no ha participado
        require(haSolicitado[msg.sender], "Usted aun no ha participado");

        // emitir evento de quemar los tokens
        emit BurnCrossChain(msg.sender, quemaTokensParticipar);
    }

    function darOtroChance(
        address _account
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        haSolicitado[_account] = false;
    }

    ///////////////////////////////////////////////////////////////
    ////                     HELPER FUNCTIONS                  ////
    ///////////////////////////////////////////////////////////////

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _getRadomNumberBelow1000() internal view returns (uint256) {
        uint256 random = (uint256(
            keccak256(abi.encodePacked(block.timestamp, msg.sender))
        ) % 1000) + 1;
        return random * 10 ** 18;
    }
}
```

## Script Publicación Airdrop

```javascript
var { ethers } = require("hardhat");

async function main() {
  const airdropOneCrossChain = await ethers.deployContract(
    "AirdropOneCrossChain"
  );
  console.log(`Address deployed: ${await airdropOneCrossChain.getAddress()}`);

  // Espera 10 confirmaciones
  var res = await airdropOneCrossChain.waitForDeployment();
  await res.deploymentTransaction().wait(10);

  await hre.run("verify:verify", {
    address: await airdropOneCrossChain.getAddress(),
    constructorArguments: [],
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1; // exitcode quiere decir fallor por error, terminacion fatal
});
```

## Contrato ERC20 en Sepolia

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MiPrimerTokenCrossChain is
    ERC20,
    ERC20Burnable,
    Pausable,
    AccessControl
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        _mint(msg.sender, 1000 * 10 ** decimals());
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(BURNER_ROLE, msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyRole(BURNER_ROLE) {
        _burn(from, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }
}
```

## Script publicación token ERC20

```javascript
var { ethers } = require("hardhat");

async function main() {
  var name = "Mi Primer Token";
  var symbol = "MPRTKN";
  const miPrimerToken = await ethers.deployContract("MiPrimerTokenCrossChain", [
    name,
    symbol,
  ]);
  console.log(`Address deployed: ${await miPrimerToken.getAddress()}`);

  // Espera 10 confirmaciones
  var res = await miPrimerToken.waitForDeployment();
  await res.deploymentTransaction().wait(10);

  await hre.run("verify:verify", {
    address: await miPrimerToken.getAddress(),
    constructorArguments: [name, symbol],
    contract: "contracts/class13/MiPrimerToken.sol:MiPrimerTokenCrossChain",
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1; // exitcode quiere decir fallor por error, terminacion fatal
});
```

<u>Nota:</u> Dentro de la opción "verify:verify", se in cluye la propiedad `contract` en el caso se tenga que especificar la ruta exacta del `bytecode` a usar. Ello porque en algún otro lugar de nuestro proyecto tenemos otro contrato que produce el mismo `bytecode`. Remover si no es necesario.

## Comandos

```
npx hardhat --network sepolia run scripts/[ruta archivo token].js
npx hardhat --network mumbai run scripts/[ruta archivo airdrop].js
```

## Guía gráfica (Sepolia -> Mumbai)

![open zeppelin defender sepolia mumbai airdrop](https://github.com/Blockchain-Bites/solidity-book/assets/3300958/968ac6b3-a689-43ab-b3b7-e98bbadc68bf)

## Tarea

1. Pega aquí la transacción hash de Mumbai luego de participar en Airdrop:
2. Pega aquí la transacción hash de Sepolia que acuña los tokens ERC20: