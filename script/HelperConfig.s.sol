// SDPX-License-Identifier: MIT

import {Script} from 'forge-std/Script.sol';
import {MockV3Aggregator} from '../test/mocks/MockV3Aggregator.sol';

contract HelperConfig is Script {
    // if we are on a local anvil, we deploy mocks
    // otherwise, grap teh existing address from the live network
    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }


    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if(block.chainid == 11155111){
            activeNetworkConfig = getSepoliaConfig();
        }else if (block.chainid == 1){
            activeNetworkConfig = getMainNetEthConfig();
        }else{
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }
    function getSepoliaConfig() public pure returns(NetworkConfig memory) {
        // price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 
        });  
        return sepoliaConfig;
    }

    function getMainNetEthConfig() public pure returns(NetworkConfig memory){
        NetworkConfig memory mainNetEthConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return mainNetEthConfig;

    }

    function getOrCreateAnvilConfig()  public returns(NetworkConfig memory){
        if(activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();
  
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });

        return anvilConfig;



    }
}  