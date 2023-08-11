
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
     function getPrice (AggregatorV3Interface priceFeed) internal  view  returns (uint256){
        // AggregatorV3Interface dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (
            /* uint80 roundID */,
            int256 answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/

             ) = priceFeed.latestRoundData();

        return uint256(answer * 1e10);
    }

    function getConversionRate (
        uint256 _ethAmount, 
        AggregatorV3Interface priceFeed
        ) internal  view returns(uint256) {

        uint256  ethPrice =  getPrice(priceFeed);

        uint256 ethAmountInUSD = (ethPrice * _ethAmount)/ 1e18;
        return ethAmountInUSD;


    }
}