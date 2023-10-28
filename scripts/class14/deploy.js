var { ethers } = require("hardhat");
var pEth = ethers.parseEther;

//este script ejecutarlo en goerli: npx hardhat --network goerli run .\scripts\class14\deploy.js

//owner: 0xB0E2767D2Fa53b55dB85892a8DCb52350c56FF14

// TokenA: 0xfE1D1baf65CDc426B9fc21a31519711525F38c97
// TokenB: 0xFc72EBe7475FAdea35CbeDd804F4a353da3285C3
// LiquidityProvider: 
// Swapper: 
// Pool:
var owner="";
var tokenAAdress="";
var tokenBAdress="";
var lpAdress="";
var swapperAddress="";
var routerAddress = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
var factoryAddress = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f";
var poolAddress="";

async function obtenerSigners(){
  [owner] = await ethers.getSigners();
  console.log("owner:" + owner);
}

async function deployTokens() {
  var tokenA = await ethers.deployContract("TokenA");

  tokenAAdress = await tokenA.getAddress();
  console.log("Contract TokenA address:", tokenAAdress);

  var tokenB = await ethers.deployContract("TokenB");

  tokenBAdress = await tokenB.getAddress();
  console.log("Contract TokenB address:", tokenBAdress);

  var resA = await tokenA.waitForDeployment();
  var resB = await tokenB.waitForDeployment();
  await resA.deploymentTransaction().wait(5);
  await resB.deploymentTransaction().wait(5);

  await hre.run("verify:verify", {
    address: tokenAAdress,
    constructorArguments: [],
    contract: "contracts/class14/Tokens.sol:TokenA",
  });

  await hre.run("verify:verify", {
    address: tokenBAdress,
    constructorArguments: [],
    contract: "contracts/class14/Tokens.sol:TokenB",
  });
}

async function publicarContratoLiquidity() {
  var liquidityProvider = await ethers.deployContract("LiquidityProvider", [tokenAAdress, tokenBAdress]);

  lpAdress = await liquidityProvider.getAddress();
  console.log("Contract LiquidityProvider address:", lpAdress);

  var res = await liquidityProvider.waitForDeployment();
  await res.deploymentTransaction().wait(5);

  await hre.run("verify:verify", {
    address: lpAdress,
    constructorArguments: [tokenAAdress, tokenBAdress],
    //contract: "contracts/class14/LiquidityProvider.sol:LiquidityProvider",
  });
}

var pEth = ethers.parseEther;
async function proveerLiquidez() {

  var TokenA = await ethers.getContractFactory("TokenA");
  var tokenA = TokenA.attach(tokenAAdress);

  var TokenB = await ethers.getContractFactory("TokenB");
  var tokenB = TokenB.attach(tokenBAdress);

  var LiquidityProv = await ethers.getContractFactory("LiquidityProvider");
  var liquidityProv = LiquidityProv.attach(lpAdress);

  console.log("Antes del mint");
  console.log(`Bal owner A: ${(await tokenA.balanceOf(owner)).toString()}`);
  console.log(`Bal owner B: ${(await tokenB.balanceOf(owner)).toString()}`);
  console.log(`Bal LP A: ${(await tokenA.balanceOf(lpAdress)).toString()}`);
  console.log(`Bal LP B: ${(await tokenB.balanceOf(lpAdress)).toString()}`);
  console.log(`Bal router A: ${(await tokenA.balanceOf(routerAddress)).toString()}`);
  console.log(`Bal router B: ${(await tokenB.balanceOf(routerAddress)).toString()}`);
  
  // parseEther: al numero agregale 18 ceros
  var tx = await tokenA.mint(lpAdress, pEth("200"));
  await tx.wait();
  tx = await tokenB.mint(lpAdress, pEth("100"));
  await tx.wait();

  console.log("Despues del mint, o antes de la creacion del pool de liquidez");
  console.log(`Bal owner A: ${(await tokenA.balanceOf(owner)).toString()}`);
  console.log(`Bal owner B: ${(await tokenB.balanceOf(owner)).toString()}`);
  console.log(`Bal LP A: ${(await tokenA.balanceOf(lpAdress)).toString()}`);
  console.log(`Bal LP B: ${(await tokenB.balanceOf(lpAdress)).toString()}`);
  console.log(`Bal router A: ${(await tokenA.balanceOf(routerAddress)).toString()}`);
  console.log(`Bal router B: ${(await tokenB.balanceOf(routerAddress)).toString()}`);

  var _tokenA = tokenAAdress;
  var _tokenB = tokenBAdress;
  var _amountADesired = pEth("200");
  var _amountBDesired = pEth("100");
  var _amountAMin = pEth("200");
  var _amountBMin = pEth("100");
  var _to = owner.address;
  var _deadline = new Date().getTime() + 60000;

  tx = await liquidityProv.addLiquidity(
    _tokenA,
    _tokenB,
    _amountADesired,
    _amountBDesired,
    _amountAMin,
    _amountBMin,
    _to,
    _deadline
  );
  var res = await tx.wait();

  console.log("Resultado de la creacion del pool de liquidez:");
  console.log(`Hash de la transaction: ${res.hash}`);//0x7735b1dd24448f700d49bd8189499eb25bfc86af90916cabb2c43d5ccea4ee5e

/*
https://goerli.etherscan.io/tx/0x7735b1dd24448f700d49bd8189499eb25bfc86af90916cabb2c43d5ccea4ee5e#internal
La tx nos muestra la siguiente ruta de Internal Txns:
La llamada del owner (mi billetera) al liquidityProv (llamando a su metodo addLiquidity), produjo 14 internal Transactions:
liquidityProv => TokenA (le da approve al router)
liquidityProv => TokenB (le da approve al router)
liquidityProv => Router (llamada router.addLiquidity(...) )
Router => Factory // create the pair if it doesn't exist yet | if(factory.getPair(...))
Router => Factory // then factory.createPair(...) => ojo el orden => (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
Factory => UniswapV2Pair (pool) [se crea el nuevo contrato] => pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
Factory => UniswapV2Pair (pool) => IUniswapV2Pair(pair).initialize(token0, token1);
Router => UniswapV2Pair  => UniswapV2Pair.getReserves()
Router => TokenA (llama a transferFrom para transferir a UniswapV2Pair)
Router => TokenB (llama a transferFrom para transferir a UniswapV2Pair)
Router => UniswapV2Pair  => liquidity = IUniswapV2Pair(pair).mint(to);
UniswapV2Pair => TokenB  => uint balance0 = IERC20(token0).balanceOf(address(this));
UniswapV2Pair => TokenA  => uint balance1 = IERC20(token1).balanceOf(address(this));
UniswapV2Pair => Factory => address feeTo = IUniswapV2Factory(factory).feeTo();

address UniswapV2Pair: 0xbe639228656967d1657806118cd65f32848aa157
*/

  poolAddress = await liquidityProv.getPair(tokenAAdress, tokenBAdress);
  console.log("uniswapV2Pair Address: " + poolAddress);


  const abi = [
    "function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast)"
  ];
  const poolContract = new ethers.Contract(poolAddress, abi, ethers.provider);
  
  var [ reserveUsdc, reserveBBToken ] = await poolContract.getReserves();

  console.log("reserveUsdc: " + reserveUsdc);
  console.log("reserveBBToken: " + reserveBBToken);

  console.log("Despues de la creacion del pool de liquidez");
  console.log(`Bal owner A: ${(await tokenA.balanceOf(owner)).toString()}`);
  console.log(`Bal owner B: ${(await tokenB.balanceOf(owner)).toString()}`);
  console.log(`Bal LP A: ${(await tokenA.balanceOf(lpAdress)).toString()}`);
  console.log(`Bal LP B: ${(await tokenB.balanceOf(lpAdress)).toString()}`);
  console.log(`Bal router A: ${(await tokenA.balanceOf(routerAddress)).toString()}`);
  console.log(`Bal router B: ${(await tokenB.balanceOf(routerAddress)).toString()}`);
  console.log(`Bal uniswapV2Pair A: ${(await tokenA.balanceOf(poolAddress)).toString()}`);
  console.log(`Bal uniswapV2Pair B: ${(await tokenB.balanceOf(poolAddress)).toString()}`);

}

async function publicarSwapper() {
  var swapper = await ethers.deployContract("Swapper");

  swapperAddress = await swapper.getAddress();
  console.log("Contract Swapper address:", swapperAddress);

  var res = await swapper.waitForDeployment();
  await res.deploymentTransaction().wait(5);

  await hre.run("verify:verify", {
    address: swapperAddress,
    constructorArguments: [],
  });
}

async function swapExactTokensForTokens() {

  var TokenA = await ethers.getContractFactory("TokenA");
  var tokenA = TokenA.attach(tokenAAdress);

  var TokenB = await ethers.getContractFactory("TokenB");
  var tokenB = TokenB.attach(tokenBAdress);

  var Swapper = await ethers.getContractFactory("Swapper");
  var swapper = Swapper.attach(swapperAddress);

  //var uniswapV2PairAddress= "0xbe639228656967d1657806118cd65f32848aa157";

  var tx = await tokenB.mint(swapperAddress, pEth("20"));
  await tx.wait();

  console.log("antes del swaping");
  console.log(`Bal owner A: ${(await tokenA.balanceOf(owner)).toString()}`);
  console.log(`Bal owner B: ${(await tokenB.balanceOf(owner)).toString()}`);
  console.log(`Bal LP A: ${(await tokenA.balanceOf(lpAdress)).toString()}`);
  console.log(`Bal LP B: ${(await tokenB.balanceOf(lpAdress)).toString()}`);
  console.log(`Bal router A: ${(await tokenA.balanceOf(routerAddress)).toString()}`);
  console.log(`Bal router B: ${(await tokenB.balanceOf(routerAddress)).toString()}`);
  console.log(`Bal Swap A: ${(await tokenA.balanceOf(swapperAddress)).toString()}`);
  console.log(`Bal Swap B: ${(await tokenB.balanceOf(swapperAddress)).toString()}`);
  console.log(`Bal uniswapV2Pair A: ${(await tokenA.balanceOf(poolAddress)).toString()}`);
  console.log(`Bal uniswapV2Pair B: ${(await tokenB.balanceOf(poolAddress)).toString()}`);

  var _amountIn = pEth("20");
  var _amountOutMin = pEth("20");
  var _path = [tokenBAdress, tokenAAdress];
  var _to = swapperAddress;//aca debe ir la billetera y no el swapper
  var _deadline = new Date().getTime() + 60000;
  tx = await swapper.swapExactTokensForTokens(
    _amountIn,
    _amountOutMin,
    _path,
    _to,
    _deadline
  );
  var res = await tx.wait();

  console.log("Resultado del swapExactTokensForTokens:");
  console.log(res.hash);

  // Bal Swap A: 33249958312489578122
  // Bal Swap B: 0
  // Bal LP A: 200000000000000000000
  // Bal LP B: 0

  console.log("despues del swaping");
  console.log(`Bal owner A: ${(await tokenA.balanceOf(owner)).toString()}`);
  console.log(`Bal owner B: ${(await tokenB.balanceOf(owner)).toString()}`);
  console.log(`Bal LP A: ${(await tokenA.balanceOf(lpAdress)).toString()}`);
  console.log(`Bal LP B: ${(await tokenB.balanceOf(lpAdress)).toString()}`);
  console.log(`Bal router A: ${(await tokenA.balanceOf(routerAddress)).toString()}`);
  console.log(`Bal router B: ${(await tokenB.balanceOf(routerAddress)).toString()}`);
  console.log(`Bal Swap A: ${(await tokenA.balanceOf(swapperAddress)).toString()}`);
  console.log(`Bal Swap B: ${(await tokenB.balanceOf(swapperAddress)).toString()}`);
  console.log(`Bal uniswapV2Pair A: ${(await tokenA.balanceOf(poolAddress)).toString()}`);
  console.log(`Bal uniswapV2Pair B: ${(await tokenB.balanceOf(poolAddress)).toString()}`);
}

async function swapTokensForExactTokens() {
  var [owner] = await ethers.getSigners();

  var tokenAAdd = "0x86d02251E5a05E87309a787230208dB9dFcB42FA";
  var TokenA = await ethers.getContractFactory("TokenA");
  var tokenA = TokenA.attach(tokenAAdd);

  var tokenBAdd = "0xbf227f4d07aaF798f49f7D97C36b79e9E67fE050";
  var TokenB = await ethers.getContractFactory("TokenB");
  var tokenB = TokenB.attach(tokenBAdd);

  var swapperAdd = "0x0A5e44C07b189662269cd715D5a65Ba4075a3Ef3";
  var Swapper = await ethers.getContractFactory("Swapper");
  var swapper = Swapper.attach(swapperAdd);

  var lpAdd = "0x8FbD48Ed31A27ebaa5AeDcC0a44d2e189cd0749a";
  // Balance de Swapper (lo que tenemos)
  // Token A Bal:  33249958312489578122
  // Token B Bal:  0

  // Balance Liquidity Pool
  // Token A Bal:  166750041687510421878 ~ 166 A
  // Token B Bal:  120000000000000000000 ~ 120 B

  // El ratio de tokens A a tokens B es 2:1
  // Vamos a solicitar la cantidad exacta de 10 tokens B (porque tenemos tokens A)
  // No sabemos cuantos tokens B necesitamos para obtener 10 tokens A
  // Atravès del liquidity pool, se intercambirá los tokens A por tokens B

  //   A       B              A        B     B
  // (166) * (120) = K = (166 + X) * (120 - 10)
  // 19920 = (166 + X) * (110)
  // X ~ 15

  // Enviar tokens A al contrato Swapper
  var amountOut = pEth("10"); // 10 tokens B
  var amountInMax = pEth("20"); // Aprox, estoy dispuesto a entregar 20 tokens A
  var path = [tokenAAdd, tokenBAdd];
  var to = swapperAdd;
  var deadline = new Date().getTime() + 10000;

  var tx = await swapper.swapTokensForExactTokens(
    amountOut,
    amountInMax,
    path,
    to,
    deadline
  );

  var res = await tx.wait();
  console.log("Transaction Hash", res.hash);

  console.log("Bal Swapp A: ", (await tokenA.balanceOf(swapperAdd)).toString());
  console.log("Bal Swapp B: ", (await tokenB.balanceOf(swapperAdd)).toString());
  console.log("Bal LiquP A: ", (await tokenA.balanceOf(lpAdd)).toString());
  console.log("Bal LiquP B: ", (await tokenB.balanceOf(lpAdd)).toString());
}

async function main() {
  await obtenerSigners();
  await deployTokens();
  await publicarContratoLiquidity();
  await proveerLiquidez();
  await publicarSwapper();
  await swapExactTokensForTokens();
  //await swapTokensForExactTokens();
}
main();