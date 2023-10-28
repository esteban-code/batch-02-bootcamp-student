// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IUniswapV2Router02 {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract Swapper {
    address routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    IUniswapV2Router02 router = IUniswapV2Router02(routerAddress);

    event SwapAmounts(uint[] amounts);

    // path
    // es como la ruta o camino hacia donde quieres llegar
    // [tokenB, tokenA] = voy a entregar tokens B para obtener tokens A
    // [tokenA, tokenB] = voy a entregar tokens A para obtener tokens B
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) public {
        address origenToken = path[0];
        IERC20(origenToken).approve(routerAddress, amountIn);

        uint[] memory _amounts = router.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            to,
            deadline
        );

        emit SwapAmounts(_amounts);
    }

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path, // [token a entregar, token a recibir]
        address to,
        uint deadline
    ) public {
        address origenToken = path[0];
        IERC20(origenToken).approve(routerAddress, amountInMax);

        uint256[] memory _amounts = router.swapTokensForExactTokens(
            amountOut,
            amountInMax,
            path,
            to,
            deadline
        );
        emit SwapAmounts(_amounts);
    }
}
