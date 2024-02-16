// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AreaToken is ERC20, Ownable {
    mapping(string => uint256) public areaAllocations;
    mapping(address => string) public userAreas;
    mapping(address => bool) public hasClaimed;

    constructor() ERC20("AreaToken", "ATK") {}

    // Function to mint new tokens (onlyOwner to restrict access)
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // Allocate tokens to a specific area
    function allocateTokensToArea(string memory area, uint256 amount) public onlyOwner {
        areaAllocations[area] += amount;
    }

    // Register user area
    function registerUserArea(string memory area) public {
        require(bytes(userAreas[msg.sender]).length == 0, "User area already registered.");
        userAreas[msg.sender] = area;
    }

    // Claim tokens by residents
    function claimTokens() public {
        require(bytes(userAreas[msg.sender]).length > 0, "User area not registered.");
        require(!hasClaimed[msg.sender], "Tokens already claimed.");
        
        string memory userArea = userAreas[msg.sender];
        require(areaAllocations[userArea] > 0, "No tokens allocated for this area.");

        hasClaimed[msg.sender] = true;
        _mint(msg.sender, areaAllocations[userArea]);
    }

    // Optional: Update user area (if users can change their registered area)
    function updateUserArea(string memory newArea) public {
        require(bytes(userAreas[msg.sender]).length > 0, "User area not registered.");
        require(!hasClaimed[msg.sender], "Cannot change area after claiming tokens.");
        userAreas[msg.sender] = newArea;
    }
}