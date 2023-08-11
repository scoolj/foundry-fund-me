// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

using PriceConverter for uint256; 

error FundMe__notOwner();

contract FundMe {
 
    address[]  private s_funders;
    mapping(address => uint256)  private s_addressToAmountFunded;
    uint256 public constant MINIMUM_USD  = 5e18;
    AggregatorV3Interface private s_priceFeed;
    // uint256 public myValue = 1;

    address private immutable i_owner;

   constructor(address priceFeed){
       //   2514
       //   444 

       i_owner = msg.sender;
       s_priceFeed = AggregatorV3Interface(priceFeed);
   }

    // 	2407 
    //  307

    function fund ()  public payable {

        // myValue +=2;
        require( msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "insufficient Amount");
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;


    }

    function withdrawal() public onlyOwner {
        
        for(uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++){
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // funders reset
        s_funders = new address[](0);

        // transfer

        // payable(msg.sender).transfer(address(this).balance);

        // send

    //   bool sendSuccess = payable(msg.sender).send(address(this).balance);
    //     require(sendSuccess, "Send fail");

        // call
      (bool callSuccess, )=payable(msg.sender).call{value: address(this).balance}("");
      require(callSuccess, "call fail");


    }

   
    modifier  onlyOwner{

        // require(msg.sender == i_owner, "This must be call by the owner");
        if(msg.sender != i_owner){
            revert FundMe__notOwner();
        }
        _;
    }


    receive() external  payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function getVersion() public view returns(uint256){
        return s_priceFeed.version();
    }


    function getAddressToAmountFunded(address fundingAddress) public view returns(uint256){
        return s_addressToAmountFunded[fundingAddress];
    }

 

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }


}