pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Exchange {
    //erc20 的代币
    address public tokenTestAddress;

    //设置erc20 代币
    constructor(address _token) {
        tokenTestAddress = _token;
    }

    //增加流动性，就是增加给当前合约多少代币 后续会有花
    function addLiquidity(uint256 amount) public payable {
        IERC20 token = IERC20(tokenTestAddress);
        token.transferFrom(msg.sender, address(this), amount);
    }

    //当前合约有多少代币
    function getReserve() public returns (uint256) {
        return IERC20(tokenTestAddress).balanceOf(address(this));
    }

    function getPrice(
        uint256 inputReserve,
        uint256 outputReserve
    ) public pure returns (uint256) {
        require(inputReserve > 0 && outputReserve > 0, "error");
        return inputReserve / outputReserve;
    }

    function getAmount(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) public pure returns (uint256) {
        require(inputAmount > 0, "error");
        //根据xy=k
        //
        //得出(x+Δx)(y-Δy) = xy
        // = (x+Δx)(y-Δy)/(x+Δx) = xy/(x+Δx)
        // = y-Δy = xy/(x+Δx)
        // = y-Δy -y  = xy/(x+Δx) -y
        // = Δy = xy/(x+Δx) -y
        // = 进行通分
        // Δy  = xy/(x+Δx) - y(x+Δx) / (x+Δx)
        // Δy  = (xy- y(x+Δx))  / (x+Δx)
        // Δy =  (xy-xy+Δxy) / (x+Δx)
        //Δy  = Δxy / (x+Δx)
        //得出需要增加的数量output数量
        return (inputAmount * outputReserve) / (inputReserve + inputAmount);
    }

    function getTokenAmount(uint256 _ethSold) public returns (uint256) {
        require(_ethSold > 0, "ethSold is too small");

        uint256 tokenReserve = getReserve();

        return getAmount(_ethSold, address(this).balance, tokenReserve);
    }

    function getEthAmount(uint256 _tokenSold) public returns (uint256) {
        require(_tokenSold > 0, "tokenSold is too small");

        uint256 tokenReserve = getReserve();

        return getAmount(_tokenSold, tokenReserve, address(this).balance);
    }

    function ethToTokenSwap(uint256 _minTokens) public payable {
        uint256 tokenReserve = getReserve();
        uint256 tokensBought = getAmount(
            msg.value,
            address(this).balance - msg.value,
            tokenReserve
        );

        require(tokensBought >= _minTokens, "insufficient output amount");

        IERC20(tokenTestAddress).transfer(msg.sender, tokensBought);
    }

    function tokenToEthSwap(uint256 _tokensSold, uint256 _minEth) public {
        uint256 tokenReserve = getReserve();
        uint256 ethBought = getAmount(
            _tokensSold,
            tokenReserve,
            address(this).balance
        );

        require(ethBought >= _minEth, "insufficient output amount");

        IERC20(tokenTestAddress).transferFrom(
            msg.sender,
            address(this),
            _tokensSold
        );
        payable(msg.sender).transfer(ethBought);
    }
}
