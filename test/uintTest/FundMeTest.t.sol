// SPDX-LIcense-Indentifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from 'forge-std/Test.sol';

import {FundMe} from '../../src/FundMe.sol';

import {DeployFundMe} from '../../script/DeployFundMe.s.sol';


contract FundMeTest is Test{

    address USER  =  makeAddr("user");
    uint256 constant SEND_AMOUNT = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    FundMe fundMe;
    function setUp() external{
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }   

    function testMinimumDollarIsFive() public {
        console.log("Test me");
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMessageSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    // function testWithdrawalIsCallByOnlyOwner() public{
    //     assertEq(fundMe.withdrawal(), msg.sender);
    // }

    function testPriceFeedVersionIsAccurate() public {
         uint256 version = fundMe.getVersion();
         assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
      vm.expectRevert();  // hey, the next line should revert

      fundMe.fund(); //  send 0 value
    }

    function testFundUpdatesFundedDataStructure() public {

        vm.prank(USER);

        fundMe.fund{value: SEND_AMOUNT}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_AMOUNT);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_AMOUNT}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);

    }

    modifier funded () {
        vm.prank(USER);
        fundMe.fund{value: SEND_AMOUNT}();

        _;
    }
    
    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdrawal();
    }
    function testWithDrawWithASingleFunder() public funded {
        // Arrange

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;


        // Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdrawal();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("Gas usage: ",gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;

        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            //vm.prank new address
            // vm.deal new address
            // fund the fundMe

            hoax(address(i), SEND_AMOUNT);
            fundMe.fund{value: SEND_AMOUNT}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act

        vm.startPrank(fundMe.getOwner());
        fundMe.withdrawal();
        vm.stopPrank();


        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }
}

