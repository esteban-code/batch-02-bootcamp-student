# Contratos Actualizables

***Ir a intranet y seguir el siguiente código con el video de explicación***

1. Dirigirte al [wizard](https://wizard.openzeppelin.com/) y obtén el siguiente código:

   ```solidity
   // SPDX-License-Identifier: MIT
   pragma solidity 0.8.19;
   
   import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
   import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
   import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
   import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
   import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
   
   /// @custom:security-contact lee.marreros@blockchainbites.co
   contract LMTokenUpgradeable is
       Initializable,
       ERC20Upgradeable,
       PausableUpgradeable,
       AccessControlUpgradeable,
       UUPSUpgradeable
   {
       bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
       bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
       bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
   
       /// @custom:oz-upgrades-unsafe-allow constructor
       constructor() {
           _disableInitializers();
       }
   
       function initialize() public initializer {
           __ERC20_init("LM Token Upgradeable", "LMTKNUPGRDBL");
           __Pausable_init();
           __AccessControl_init();
           __UUPSUpgradeable_init();
   
           _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
           _grantRole(PAUSER_ROLE, msg.sender);
           _grantRole(MINTER_ROLE, msg.sender);
           _grantRole(UPGRADER_ROLE, msg.sender);
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
   
       function _beforeTokenTransfer(
           address from,
           address to,
           uint256 amount
       ) internal override whenNotPaused {
           super._beforeTokenTransfer(from, to, amount);
       }
   
       function _authorizeUpgrade(
           address newImplementation
       ) internal override onlyRole(UPGRADER_ROLE) {}
   }
   ```

2. Desarrollamos el script de publicación de la versión 1:

   ```javascript
   const { ethers, upgrades } = require("hardhat");
   
   // Address Contrato Proxy: 0xF8B71dD7df036a256150D5bb5998E3289beE5E70
   async function main() {
     // obtener el código del contrato
     var UpgradeableToken = await ethers.getContractFactory("LMTokenUpgradeable");
   
     // publicar el proxy
     var upgradeableToken = await upgrades.deployProxy(UpgradeableToken, [], {
       kind: "uups",
     });
   
     // esperar a que se confirme el contrato - 5 confirmaciones
     var tx = await upgradeableToken.waitForDeployment();
     await tx.deploymentTransaction().wait(5);
   
     // obtenemos el address de implementación
     var implementationAdd = await upgrades.erc1967.getImplementationAddress(
       await upgradeableToken.getAddress()
     );
   
     console.log(`Address del Proxy es: ${await upgradeableToken.getAddress()}`);
     console.log(`Address de Impl es: ${implementationAdd}`);
   
     // hacemos la verificación del address de implementación
     await hre.run("verify:verify", {
       address: implementationAdd,
       constructorArguments: [],
     });
   }
   
   main().catch((error) => {
     console.error(error);
     process.exitCode = 1; // nodeJs | 1 significa que falló la operación
   });
   ```

3. Desarolla una actualización del contrato de implementación:

   ```solidity
   // SPDX-License-Identifier: MIT
   pragma solidity 0.8.19;
   
   import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
   import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
   import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
   import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
   import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
   
   /// @custom:security-contact lee.marreros@blockchainbites.co
   contract LMTokenUpgradeable is
       Initializable,
       ERC20Upgradeable,
       PausableUpgradeable,
       AccessControlUpgradeable,
       UUPSUpgradeable
   {
       bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
       bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
       bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
   
       /// @custom:oz-upgrades-unsafe-allow constructor
       constructor() {
           _disableInitializers();
       }
   
       function initialize() public initializer {
           __ERC20_init("LM Token Upgradeable", "LMTKNUPGRDBL");
           __Pausable_init();
           __AccessControl_init();
           __UUPSUpgradeable_init();
   
           _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
           _grantRole(PAUSER_ROLE, msg.sender);
           _grantRole(MINTER_ROLE, msg.sender);
           _grantRole(UPGRADER_ROLE, msg.sender);
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
   
       function mint(uint256 amount) public {
           _mint(msg.sender, amount);
       }
   
       function _beforeTokenTransfer(
           address from,
           address to,
           uint256 amount
       ) internal override whenNotPaused {
           super._beforeTokenTransfer(from, to, amount);
       }
   
       function _authorizeUpgrade(
           address newImplementation
       ) internal override onlyRole(UPGRADER_ROLE) {}
   
       function version() public pure returns (uint256) {
           return 2;
       }
   }
   ```

4. Desarrolla el script de actualización para la versión 2:

   ```javascript
   const { ethers, upgrades } = require("hardhat");
   
   async function upgrade() {
     const ProxyAddress = "0xF8B71dD7df036a256150D5bb5998E3289beE5E70";
     const LMTokenUpgradeableV2 = await ethers.getContractFactory(
       "LMTokenUpgradeable"
     );
     const lmTokenUpgradeableV2 = await upgrades.upgradeProxy(
       ProxyAddress,
       LMTokenUpgradeableV2
     );
   
     // esperar unas confirmaciones
   
     var implV2 = await upgrades.erc1967.getImplementationAddress(ProxyAddress);
     console.log(`Address Proxy: ${ProxyAddress}`);
     console.log(`Address Impl V2: ${implV2}`);
   
     await hre.run("verify:verify", {
       address: implV2,
       constructorArguments: [],
     });
   }
   
   upgrade().catch((error) => {
     console.error(error);
     process.exitCode = 1; // nodeJs | 1 significa que falló la operación
   });
   
   ```

   

