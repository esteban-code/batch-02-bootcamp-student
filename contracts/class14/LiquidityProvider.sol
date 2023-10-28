// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Address es en Ethereum y Testnets (Goerli)
// address: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D

interface IUniswapV2Router02 {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external returns (uint amountIn);
}

// Factory: consultar el address del LP token
// address: 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
interface IUniswapV2Factory {
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

contract LiquidityProvider {
    address routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    IUniswapV2Router02 router = IUniswapV2Router02(routerAddress);

    address factoryAddress = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    IUniswapV2Factory factory = IUniswapV2Factory(factoryAddress);

    IERC20 tokenA;
    IERC20 tokenB;

    constructor(address tokenAAdress, address tokenBAddress){
        tokenA = IERC20(tokenAAdress);
        tokenB = IERC20(tokenBAddress);
    }

    event LiquidityAddres(
        uint256 amountA,
        uint256 amountB,
        uint256 amountLpTokens
    );

    function addLiquidity(
        address _tokenA,
        address _tokenB,
        uint _amountADesired,
        uint _amountBDesired,
        uint _amountAMin,
        uint _amountBMin,
        address _to,
        uint _deadline
    ) public {
        tokenA.approve(routerAddress, _amountADesired);
        tokenB.approve(routerAddress, _amountBDesired);

        uint256 amountA;
        uint256 amountB;
        uint256 amountLP;
        (amountA, amountB, amountLP) = router.addLiquidity(
            _tokenA,
            _tokenB,
            _amountADesired,
            _amountBDesired,
            _amountAMin,
            _amountBMin,
            _to,
            _deadline
        );

        emit LiquidityAddres(amountA, amountB, amountLP);
    }

    function getPair(
        address _tokenA,
        address _tokenB
    ) public view returns (address) {
        return factory.getPair(_tokenA, _tokenB);
    }
}
