// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Abuelo {
    modifier contento() virtual {
        _;
    }
}

contract Padre {
    modifier contento() virtual {
        _;
    }
}

contract Hijo is Abuelo, Padre {
    modifier contento() override(Abuelo, Padre) {
        _;
    }
}
