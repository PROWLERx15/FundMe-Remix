// Get Funds from Users
//Withdraw Funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {PriceConvertor} from "./PriceConvertor.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 783312 gas
// 762939 gas with constant

error NotOwner();

contract FundMe
{
    using PriceConvertor for uint256;

    uint256 public constant MINIMUM_USD = 5e18; // minimum amt of USD to be sent = $5
    // 2402 gas - non constant
    // 325 gas - with constant

    address[] public funders;  // to store address of funders
    mapping (address funders => uint256 amountFunded) public AddressToAmountFunded;

    address public immutable i_owner;
    // 2552 gas - without immutable
    // 417 gas - with immutable

    constructor()
    {
        i_owner = msg.sender;
    }

    function Fund() public payable   // How do we send ETH to this contract? - Use "payable"
    {
        // Allow users to send $
        // Have a minimum $ sent
        

        //msg.value.getConversonRate();  

        require(msg.value.getConversionRate() >= MINIMUM_USD, "NOT ENOUGH ETH SENT"); 
        
        funders.push(msg.sender);
        AddressToAmountFunded[msg.sender] = AddressToAmountFunded[msg.sender] + msg.value;

        // What is a revert?
        // Undo any actions that have been done, and send the remaining gas back
        // Even if the transaction reverts, since some computation occured. Gas is spent

    }

    function getVersion() public view returns (uint256) 
    {
        return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
    }

    function Withdraw() public onlyOwner
    {
        
        
        for (uint256 funderindex=0; funderindex<funders.length;funderindex++) 
        {
            address funder = funders[funderindex];
            AddressToAmountFunded[funder] = 0;
        }
        funders = new address[](0); // reset the funders array 

        // actually withdraw the funds

        /* 
        
        transfer (2300 gas, throws error)

        msg.sender = address
        payable(msg.sender) = payable address 

        payable (msg.sender).transfer(address(this).balance);


        send (2300 gas, returns bool)

        bool sendSuccess = payable (msg.sender).send(address(this).balance);
        require(sendSuccess, "Send Failed");

        */

        // call (forward all gas or set gas, returns bool)

        (bool callSuccess,) = payable (msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");

    }

    modifier onlyOwner()
    {
       // require(msg.sender == i_owner, "MUST BE OWNER" );
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }


    // What happens when someone sends ETH to this contract without using the fund function
    
    // receive()
    // fallback()

    receive() external payable { Fund(); }
    fallback() external payable { Fund(); }
}
