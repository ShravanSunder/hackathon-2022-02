pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "hardhat/console.sol";

contract PriceOracleNFT is ChainlinkClient {
  using Chainlink for Chainlink.Request;
  uint256 public price;
  string public test = "failed";

  address private oracle;
  bytes32 private jobId;
  uint256 private fee;

  /*
    ---------------------------------
    CHAINLINK-POLYGON NETWORK DETAILS
    ---------------------------------
    name: "mumbai",
    linkToken: "0x326C977E6efc84E512bB9C30f76E30c160eD06FB",
    ethUsdPriceFeed: "0x0715A7794a1dc8e42615F059dD6e406A6594651A",
    keyHash:
      "0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4",
    vrfCoordinator: "0x8C7382F9D8f56b33781fE506E897a4F1e2d17255",
    oracle: "0x58bbdbfb6fca3129b91f0dbe372098123b38b5e9",
    jobId: "da20aae0e4c843f6949e5cb3f7cfe8c4",

    name: "polygon",
    linkToken: "0xb0897686c545045afc77cf20ec7a532e3120e0f1",
    ethUsdPriceFeed: "0xF9680D99D6C9589e2a93a78A04A279e509205945",
    keyHash:
      "0xf86195cf7690c55907b2b611ebb7343a6f649bff128701cc542f0569e2c549da",
    vrfCoordinator: "0x3d2341ADb2D31f1c5530cDC622016af293177AE0",
    oracle: "0x0a31078cd57d23bf9e8e8f1ba78356ca2090569e",
    jobId: "12b86114fa9e46bab3ca436f88e1a912",
  */
  constructor() {
    setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
    oracle = 0x58BBDbfb6fca3129b91f0DBE372098123B38B5e9;
    jobId = "da20aae0e4c843f6949e5cb3f7cfe8c4";
    fee = 0.01 * 10**18;
  }

  /**
   * Create a Chainlink request to retrieve API response, find the target price
   * data, then multiply by 100 (to remove decimal places from price).
   */
  function requestBTCUSDPrice() public returns (bytes32 requestId) {
    Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

    // Set the URL to perform the GET request on
    request.add("get", "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=ETH&tsyms=USD");

    // Set the path to find the desired data in the API response, where the response format is:
    // {"RAW":
    //   {"ETH":
    //    {"USD":
    //     {
    //      "VOLUME24HOUR": xxx.xxx,
    //     }
    //    }
    //   }
    //  }
    request.add("path", "RAW.ETH.USD.PRICE");

    // // Multiply the result by 1000000000000000000 to remove decimals
    // int256 timesAmount = 10**18;
    // request.addInt("times", timesAmount);

    // Sends the request
    return sendChainlinkRequestTo(oracle, request, fee);
  }

  function fulfill(bytes32 _requestId, uint256 _price) public recordChainlinkFulfillment(_requestId) {
    price = _price;
    test = "test";
  }

  //   function stringToBytes32(string memory source) public pure returns (bytes32 result) {
  //     bytes memory tempEmptyStringTest = bytes(source);
  //     if (tempEmptyStringTest.length == 0) {
  //       return 0x0;
  //     }

  //     assembly {
  //       // solhint-disable-line no-inline-assembly
  //       result := mload(add(source, 32))
  //     }
  //   }
}
