// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract UpgradeableToken is
    Initializable,
    ERC20Upgradeable,
    UUPSUpgradeable,
    OwnableUpgradeable
{
    // mapping doble
    // defini 10 variables

    function initialize() public initializer {
        // ERC("Upgradeble Token", "UPGRDTKN")
        __ERC20_init("Upgradeble Token", "UPGRDTKN");
        __Ownable_init();
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}

contract UpgradeableToken2 is
    Initializable,
    ERC20Upgradeable,
    UUPSUpgradeable,
    OwnableUpgradeable
{
    // mapping doble
    // defini 10 variables
    // ortas nuevas variables

    function actualizarMapipngtriple() public {
        // mapping doble => mapping triple
    }

    function initialize() public initializer {
        // ERC("Upgradeble Token", "UPGRDTKN")
        __ERC20_init("Upgradeble Token", "UPGRDTKN");
        __Ownable_init();
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}
