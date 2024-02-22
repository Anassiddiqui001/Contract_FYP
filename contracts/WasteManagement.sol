// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WasteManagementSystem {

    // Structs
    struct WasteCollectionEntry {
        uint id;
        address districtAdmin;
        uint date; 
        uint totalAmount; // Total amount of waste collected
        string area;
        string notes;
       
    }
   
    struct InputOutputEntry {
        uint id;
        uint inputDate; // UNIX timestamp for input
        uint outputDate; // UNIX timestamp for output
        uint quantityReceived;
        uint recyclablePercentage;
        string area;
      
    }

     struct LandfillEntry {
        uint id;
        uint date; // UNIX timestamp for entry
        uint quantityDisposed;
        string area;
        string landfillSite;
        
    }

    struct WeeklyReport {
        uint id;
        address admin;
        string ipfsHash;
        uint date; // UNIX timestamp for the report submission
    }

    enum UserRole { DistrictAdmin, RecyclableAdmin, LandfillAdmin, User }


    // Variables
    address public owner;
  
    // Reports Ids
    uint private districtAdminReportId = 1;
    uint private recyclablePointAdminReportId = 1;
    uint private landfillAdminReportId = 1;

    // Entries Ids
    uint private wasteCollectionEntryId = 1;    // district admin
    uint private inputOutputEntryId = 1;     // recycle point admin
    uint private landfillEntryId = 1;       // landfill admin

    
    // Entries Mappings
    mapping(uint => WasteCollectionEntry) public wasteCollectionEntries;
    mapping(uint => InputOutputEntry) public inputOutputEntries;
    mapping(uint => LandfillEntry) public landfillEntries; 

    // Reports Mappings
    mapping(uint => WeeklyReport) public districtAdminReports;
    mapping(uint => WeeklyReport) public recyclablePointAdminReports;
    mapping(uint => WeeklyReport) public landfillAdminReports;

    // Roles Mappings
    mapping(address => UserRole) public userRoles;

    // Events
    event WasteCollectionRecorded(uint id, address districtAdmin, uint totalAmount, string area);
    event InputOutputRecorded(uint id, uint quantityReceived, string area);
    event LandfillEntryRecorded(uint id, uint quantityDisposed, string area, string landfillSite); 
    

    modifier onlyRole(UserRole role) {
        require(userRoles[msg.sender] == role, "Unauthorized action for user role.");
        _;
    }

    constructor() {
        owner = msg.sender;
        userRoles[owner] = UserRole.DistrictAdmin;
    }


    // District Admin
    function recordWasteCollection(uint _date, uint _totalAmount, string memory _area, string memory _notes) public onlyRole(UserRole.DistrictAdmin) {
        wasteCollectionEntries[wasteCollectionEntryId] = WasteCollectionEntry(wasteCollectionEntryId, msg.sender, _date, _totalAmount, _area, _notes);
        emit WasteCollectionRecorded(wasteCollectionEntryId, msg.sender, _totalAmount, _area);
        wasteCollectionEntryId++;
    }

      //   Recyclable Point Admin
    function recordInputOutput(uint _inputDate, uint _outputDate, uint _quantityReceived, uint _recyclablePercentage, string memory _area) public onlyRole(UserRole.RecyclableAdmin) {
        inputOutputEntries[inputOutputEntryId] = InputOutputEntry(inputOutputEntryId, _inputDate, _outputDate, _quantityReceived, _recyclablePercentage, _area);
        emit InputOutputRecorded(inputOutputEntryId, _quantityReceived, _area);
        inputOutputEntryId++;
    }

      function recordLandfillEntry(uint _date, uint _quantityDisposed, string memory _area, string memory _landfillSite) public onlyRole(UserRole.LandfillAdmin) {
        landfillEntries[landfillEntryId] = LandfillEntry(landfillEntryId, _date, _quantityDisposed, _area, _landfillSite);
        emit LandfillEntryRecorded(landfillEntryId, _quantityDisposed, _area, _landfillSite);
        landfillEntryId++;
    }

    
 
    // Additional logic to assign roles to users
    function assignUserRole(address _user, UserRole _role) public {
        require(msg.sender == owner, "Only the contract owner can assign roles.");
        userRoles[_user] = _role;
    }

    // Function to allow district admins to update waste collection records (if necessary)
    function updateWasteCollectionEntry(uint _id, uint _totalAmount, string memory _notes) public onlyRole(UserRole.DistrictAdmin) {
        require(_id < wasteCollectionEntryId, "Waste collection entry does not exist.");
        WasteCollectionEntry storage entry = wasteCollectionEntries[_id];
        entry.totalAmount = _totalAmount;
        entry.notes = _notes;
        emit WasteCollectionRecorded(_id, entry.districtAdmin, _totalAmount, entry.area);
    }


    
    // Function to get a waste collection entry by its ID
    function getWasteCollectionEntry(uint _id) public view returns (WasteCollectionEntry memory) {
        require(_id < wasteCollectionEntryId, "Waste collection entry does not exist.");
        return wasteCollectionEntries[_id];
    }


      // Function to get an input-output entry by its ID
    function getInputOutputEntry(uint _id) public view returns (InputOutputEntry memory) {
        require(_id < inputOutputEntryId, "Input-output entry does not exist.");
        return inputOutputEntries[_id];
    }

    // Function to get an landfill entry by its ID
     function getLandfillEntry(uint _id) public view returns (LandfillEntry memory) {
        require(_id < landfillEntryId, "Landfill entry does not exist.");
        return landfillEntries[_id];
    }


        // Getter functions for the reports
    function getDistrictAdminReport(uint _id) public view returns (WeeklyReport memory) {
        require(_id < districtAdminReportId, "District Admin report does not exist.");
        return districtAdminReports[_id];
    }

    function getRecyclablePointAdminReport(uint _id) public view returns (WeeklyReport memory) {
        require(_id < recyclablePointAdminReportId, "Recyclable Point Admin report does not exist.");
        return recyclablePointAdminReports[_id];
    }

    function getLandfillAdminReport(uint _id) public view returns (WeeklyReport memory) {
        require(_id < landfillAdminReportId, "Landfill Admin report does not exist.");
        return landfillAdminReports[_id];
    }

}
