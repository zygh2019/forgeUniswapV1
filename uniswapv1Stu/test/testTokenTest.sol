// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";
import "../src/TokenTest.sol";
import "../src/Exchage.sol";

contract testTokenTest is Test {
    TokenTest tokenTest;
    Exchange exchange;

    function setUp() public {
        // 部署合约 - 使用owner作为部署者
        tokenTest = new TokenTest();
        exchange = new Exchange(address(tokenTest));
    }

    function testAddLiquidity() public {
        tokenTest.approve(address(exchange), 1000);
        exchange.addLiquidity{value: 1 ether}(1000);
    }

    function testgetPrice() public {
        tokenTest.approve(address(exchange), 1e18);
        exchange.addLiquidity{value: 1 ether}(1e18);
        uint256 tokenPrice = exchange.getPrice(
            address(exchange).balance,
            exchange.getReserve()
        );
        assertEq(tokenPrice, 1);
    }

    function testgetAmount() public {
        tokenTest.approve(address(exchange), 2000 ether);
        exchange.addLiquidity{value: 1000 ether}(2000 ether);

        assertEq(exchange.getReserve(), 2000 ether);
        assertEq(address(exchange).balance, 1000 ether);

        uint256 ethAmount = exchange.getTokenAmount(1 ether);
        assertEq(ethAmount, 1998001998001998001);
         uint256 tokenAmount = exchange.getEthAmount(2 ether);
        assertEq(tokenAmount, 19980019980019980011);
    }

    // 测试初始供应量
}
