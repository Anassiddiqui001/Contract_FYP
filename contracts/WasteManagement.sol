// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WasteManagementSystem {

    struct WasteCollectionEntry {
        uint id;
        address districtAdmin;
        uint date; // UNIX timestamp
        uint totalAmount; // Total amount of waste collected
        string area;
        string notes;
        string imageIPFSHash; // Storing IPFS hash for the image
    }

    struct ComplaintEntry {
        uint id;
      
        string responseIPFSHash; // IPFS hash for response data
    }

    struct InputOutputEntry {
        uint id;
        uint inputDate; // UNIX timestamp for input
        uint outputDate; // UNIX timestamp for output
        uint quantityReceived;
        uint recyclablePercentage;
        string area;
        string inputImageIPFSHash; // IPFS hash for input image
        string outputImageIPFSHash; // IPFS hash for output image
    }

    // enum Status { Discarded, Pending, Resolved }
    enum UserRole { DistrictAdmin, RecyclableAdmin, LandfillAdmin, User }

    address public owner;
    
    mapping(uint => WasteCollectionEntry) public wasteCollectionEntries;
    mapping(uint => ComplaintEntry) public complaintEntries;
    mapping(uint => InputOutputEntry) public inputOutputEntries;
    mapping(address => UserRole) public userRoles;

    uint private wasteCollectionEntryId = 1;
    uint private complaintEntryId = 1;
    uint private inputOutputEntryId = 1;

    event WasteCollectionRecorded(uint id, address districtAdmin, uint totalAmount, string area);
    // event ComplaintRecorded(uint id, address userId, string area, Status status);
    event InputOutputRecorded(uint id, uint quantityReceived, string area);
    event IPFSHashStored(string ipfsHash);

    modifier onlyRole(UserRole role) {
        require(userRoles[msg.sender] == role, "Unauthorized action for user role.");
        _;
    }

    constructor() {
        owner = msg.sender;
        userRoles[owner] = UserRole.DistrictAdmin;
    }

    function recordWasteCollection(uint _date, uint _totalAmount, string memory _area, string memory _notes, string memory _imageIPFSHash) public onlyRole(UserRole.DistrictAdmin) {
        wasteCollectionEntries[wasteCollectionEntryId] = WasteCollectionEntry(wasteCollectionEntryId, msg.sender, _date, _totalAmount, _area, _notes, _imageIPFSHash);
        emit WasteCollectionRecorded(wasteCollectionEntryId, msg.sender, _totalAmount, _area);
        wasteCollectionEntryId++;
    }

  

    function recordInputOutput(uint _inputDate, uint _outputDate, uint _quantityReceived, uint _recyclablePercentage, string memory _area, string memory _inputImageIPFSHash, string memory _outputImageIPFSHash) public {
        inputOutputEntries[inputOutputEntryId] = InputOutputEntry(inputOutputEntryId, _inputDate, _outputDate, _quantityReceived, _recyclablePercentage, _area, _inputImageIPFSHash, _outputImageIPFSHash);
        emit InputOutputRecorded(inputOutputEntryId, _quantityReceived, _area);
        inputOutputEntryId++;
    }

    function storeReportIPFSHash(string memory _ipfsHash) public {
        emit IPFSHashStored(_ipfsHash);
    }

  

    // Function to get a waste collection entry by its ID
    function getWasteCollectionEntry(uint _id) public view returns (WasteCollectionEntry memory) {
        require(_id < wasteCollectionEntryId, "Waste collection entry does not exist.");
        return wasteCollectionEntries[_id];
    }

    // Function to get a complaint entry by its ID
    function getComplaintEntry(uint _id) public view returns (ComplaintEntry memory) {
        require(_id < complaintEntryId, "Complaint entry does not exist.");
        return complaintEntries[_id];
    }

    // Function to get an input-output entry by its ID
    function getInputOutputEntry(uint _id) public view returns (InputOutputEntry memory) {
        require(_id < inputOutputEntryId, "Input-output entry does not exist.");
        return inputOutputEntries[_id];
    }


    // Additional logic to assign roles to users
    function assignUserRole(address _user, UserRole _role) public {
        require(msg.sender == owner, "Only the contract owner can assign roles.");
        userRoles[_user] = _role;
    }

    // Function to allow district admins to update waste collection records (if necessary)
    function updateWasteCollectionEntry(uint _id, uint _totalAmount, string memory _notes, string memory _imageIPFSHash) public onlyRole(UserRole.DistrictAdmin) {
        require(_id < wasteCollectionEntryId, "Waste collection entry does not exist.");
        WasteCollectionEntry storage entry = wasteCollectionEntries[_id];
        entry.totalAmount = _totalAmount;
        entry.notes = _notes;
        entry.imageIPFSHash = _imageIPFSHash;
        emit WasteCollectionRecorded(_id, entry.districtAdmin, _totalAmount, entry.area);
    }

}
