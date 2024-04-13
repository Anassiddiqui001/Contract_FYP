// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RecysenseIncentiveToken is ERC20, Ownable {
    
    struct Subdivision {
        uint256 totalAllocation;
        uint256 lastAllocationMonth; // Tracks the month of the last allocation to this subdivision
    }

    mapping(string => Subdivision) public subdivisions;
    mapping(address => uint256) public lastClaimMonth; // Tracks the last month a user claimed tokens
    mapping(string => string) public subdivisionToDivision; // Maps subdivision to division
    uint256 public totalSupplyCap; // Maximum supply of tokens
    mapping(address => bool) private districtAdmins; // Mapping to track district admins

    constructor(uint256 _totalSupplyCap) ERC20("RecysenseIncentiveToken", "RIT") Ownable(msg.sender) {
        totalSupplyCap = _totalSupplyCap;
        districtAdmins[msg.sender] = true; // Set deployer as the initial district admin
    }

    modifier onlyDistrictAdmin() {
        require(districtAdmins[msg.sender], "Caller is not a district admin");
        _;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        require(totalSupply() + amount <= totalSupplyCap, "Exceeds total supply cap");
        _mint(to, amount);
    }

    function allocateTokensToSubdivision(string memory subdivision, uint256 amount, uint256 month) public onlyDistrictAdmin {
        require(subdivisions[subdivision].lastAllocationMonth != month, "Already allocated this month");
        require(totalSupply() + amount <= totalSupplyCap, "Allocation exceeds cap");

        subdivisions[subdivision].totalAllocation += amount;
        subdivisions[subdivision].lastAllocationMonth = month;
        totalSupplyCap -= amount; // Decrement the cap by allocated amount
    }

    function claimTokens(string memory subdivision, uint256 month, uint256 amount) public {
        require(lastClaimMonth[msg.sender] != month, "Already claimed this month");
        require(subdivisions[subdivision].lastAllocationMonth == month, "No allocation this month");
        require(subdivisions[subdivision].totalAllocation >= amount, "Insufficient tokens allocated for this subdivision");


        lastClaimMonth[msg.sender] = month;

        subdivisions[subdivision].totalAllocation -= amount; // Deduct the claimed amount from the subdivision allocation
        _mint(msg.sender, amount); // Mint tokens based on the requested amount
    }

    function addSubdivisionToDivision(string memory subdivision, string memory division) public onlyOwner {
        subdivisionToDivision[subdivision] = division;
    }

    // Admin role management functions
    function addDistrictAdmin(address admin) public onlyOwner {
        districtAdmins[admin] = true;
    }

    function removeDistrictAdmin(address admin) public onlyOwner {
        districtAdmins[admin] = false;
    }

    // Utility function to check if an address is a district admin
    function isDistrictAdmin(address admin) public view returns (bool) {
        return districtAdmins[admin];
    }
}
