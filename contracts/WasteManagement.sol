/**
 *Submitted for verification at Etherscan.io on 2024-03-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract WasteManagementSystem {
    // Structs
    struct WasteCollectionEntry {
        uint256 id;
        address districtAdmin;
        uint256 date;
        uint256 totalAmount; // Total amount of waste collected
        string area;
        string notes;
    }

    struct InputOutputEntry {
        uint256 id;
        uint256 inputDate; // UNIX timestamp for input
        uint256 outputDate; // UNIX timestamp for output
        uint256 quantityReceived;
        uint256 recyclablePercentage;
        string area;
    }

    struct InputEntry {
        uint256 id;
        uint256 inputDate; // UNIX timestamp for input
        uint256 quantityReceived;
        string district;
        string sourceSubdivision;
        string area;
    }

    struct OutputEntry {
        uint256 id;
        uint256 outputDate; // UNIX timestamp for input
        uint256 recyclablePercentage;
        uint256 plasticPercentage;
        uint256 glassPercentage;
        uint256 metalloidsPercentage;
        uint256 marketValue;
    }

    struct LandfillEntry {
        uint256 id;
        uint256 date; // UNIX timestamp for entry
        uint256 quantityDisposed;
        string area;
        string landfillSite;
    }

    struct WeeklyReport {
        uint256 id;
        address admin;
        string ipfsHash;
        uint256 date; // UNIX timestamp for the report submission
        string reportType;
    }

    enum UserRole {
        DistrictAdmin,
        RecyclableAdmin,
        LandfillAdmin,
        User,
        None
    }

    // Variables
    mapping(address => bool) public owners; // Mapping to store owners
    mapping(address => mapping(UserRole => bool)) public userRoles; // Mapping to store user roles

    // Reports Ids
    uint256 private weeklyReportId = 1;

    // Entries Ids
    uint256 private wasteCollectionEntryId = 1; // district admin
    uint256 private inputEntryId = 1; // recycle point admin
    uint256 private outputEntryId = 1; // recycle point admin
    uint256 private landfillEntryId = 1; // landfill admin

    // Entries Mappings
    mapping(uint256 => WasteCollectionEntry) public wasteCollectionEntries;
    mapping(uint256 => InputEntry) public inputEntries;
    mapping(uint256 => OutputEntry) public outputEntries;
    mapping(uint256 => LandfillEntry) public landfillEntries;

    // Reports Mappings
    mapping(uint256 => WeeklyReport) public weeklyReports;

    // Events
    event WasteCollectionRecorded(
        uint256 id,
        address districtAdmin,
        uint256 totalAmount,
        string area
    );
    event InputEntryRecorded(
        uint256 id,
        uint256 date,
        uint256 quantityReceived,
        string _area
    );
    event OutputEntryRecorded(
        uint256 id,
        uint256 date,
        uint256 recyclablePercentage,
        uint256 marketValue
    );
    event LandfillEntryRecorded(
        uint256 id,
        uint256 quantityDisposed,
        string area,
        string landfillSite
    );
    event WeeklyReportAdded(
        uint256 id,
        address admin,
        string ipfsHash,
        string reportType
    );

    modifier onlyOwner() {
        require(
            owners[msg.sender],
            "Only the contract owner can perform this action."
        );
        _;
    }

    modifier onlyRole(UserRole role) {
        require(
            userRoles[msg.sender][role],
            "Unauthorized action for user role."
        );
        _;
    }

    constructor(address[] memory _owners) {
        for (uint256 i = 0; i < _owners.length; i++) {
            owners[_owners[i]] = true;
            userRoles[_owners[i]][UserRole.DistrictAdmin] = true;
        }
    }

    // Function to add or remove an owner
    function setOwner(address _owner, bool _status) public onlyOwner {
        owners[_owner] = _status;
    }

    // District Admin
    function recordWasteCollection(
        uint256 _date,
        uint256 _totalAmount,
        string memory _area,
        string memory _notes
    ) public onlyRole(UserRole.DistrictAdmin) {
        wasteCollectionEntries[wasteCollectionEntryId] = WasteCollectionEntry(
            wasteCollectionEntryId,
            msg.sender,
            _date,
            _totalAmount,
            _area,
            _notes
        );
        emit WasteCollectionRecorded(
            wasteCollectionEntryId,
            msg.sender,
            _totalAmount,
            _area
        );
        wasteCollectionEntryId++;
    }

    // Recycle point admin
    function recordInputEntry(
        uint256 _inputDate,
        uint256 _quantityReceived,
        string memory _district,
        string memory _sourceSubdivision,
        string memory _area
    ) public onlyRole(UserRole.RecyclableAdmin) {
        inputEntries[inputEntryId] = InputEntry(
            inputEntryId,
            _inputDate,
            _quantityReceived,
            _district,
            _sourceSubdivision,
            _area
        );
        emit InputEntryRecorded(
            inputEntryId,
            _inputDate,
            _quantityReceived,
            _area
        );
        inputEntryId++;
    }

    function recordOutputEntry(
        uint256 _outputDate,
        uint256 recyclablePercentage,
        uint256 _plasticPercentage,
        uint256 _glassPercentage,
        uint256 _metalloidsPercentage,
        uint256 _marketValue
    ) public onlyRole(UserRole.RecyclableAdmin) {
        outputEntries[outputEntryId] = OutputEntry(
            outputEntryId,
            _outputDate,
            recyclablePercentage,
            _plasticPercentage,
            _glassPercentage,
            _metalloidsPercentage,
            _marketValue
        );
        emit OutputEntryRecorded(
            outputEntryId,
            _outputDate,
            recyclablePercentage,
            _marketValue
        );
        outputEntryId++;
    }

    // Landfill admin
    function recordLandfillEntry(
        uint256 _date,
        uint256 _quantityDisposed,
        string memory _area,
        string memory _landfillSite
    ) public onlyRole(UserRole.LandfillAdmin) {
        landfillEntries[landfillEntryId] = LandfillEntry(
            landfillEntryId,
            _date,
            _quantityDisposed,
            _area,
            _landfillSite
        );
        emit LandfillEntryRecorded(
            landfillEntryId,
            _quantityDisposed,
            _area,
            _landfillSite
        );
        landfillEntryId++;
    }

    // Add weekly report function
    function addWeeklyReport(uint256 _date, string memory _ipfsHash, string memory _reportType)
        public
    {
        WeeklyReport memory newReport = WeeklyReport(
            weeklyReportId,
            msg.sender,
            _ipfsHash,
            _date,
            _reportType
        );
        weeklyReports[weeklyReportId] = newReport;
        emit WeeklyReportAdded(
            weeklyReportId,
            msg.sender,
            _ipfsHash,
            _reportType
        );
        weeklyReportId++;
    }

    // Additional logic to assign roles to users
    function assignUserRole(address _user, UserRole _role) public {
        require(
            owners[msg.sender],
            "Only the contract owner can assign roles."
        );
        userRoles[_user][_role] = true;
    }

    // Function to allow district admins to update waste collection records (if necessary)
    function updateWasteCollectionEntry(
        uint256 _id,
        uint256 _totalAmount,
        string memory _notes
    ) public onlyRole(UserRole.DistrictAdmin) {
        require(
            _id < wasteCollectionEntryId,
            "Waste collection entry does not exist."
        );
        WasteCollectionEntry storage entry = wasteCollectionEntries[_id];
        entry.totalAmount = _totalAmount;
        entry.notes = _notes;
        emit WasteCollectionRecorded(
            _id,
            entry.districtAdmin,
            _totalAmount,
            entry.area
        );
    }

    // Function to get a waste collection entry by its ID
    function getWasteCollectionEntry(uint256 _id)
        public
        view
        returns (WasteCollectionEntry memory)
    {
        require(
            _id < wasteCollectionEntryId,
            "Waste collection entry does not exist."
        );
        return wasteCollectionEntries[_id];
    }

    // Function to get an input-output entry by its ID
    function getInputEntry(uint256 _id)
        public
        view
        returns (InputEntry memory)
    {
        require(_id < inputEntryId, "Input entry does not exist.");
        return inputEntries[_id];
    }

    function getOutputEntry(uint256 _id)
        public
        view
        returns (OutputEntry memory)
    {
        require(_id < outputEntryId, "Output entry does not exist.");
        return outputEntries[_id];
    }

    // Function to get an landfill entry by its ID
    function getLandfillEntry(uint256 _id)
        public
        view
        returns (LandfillEntry memory)
    {
        require(_id < landfillEntryId, "Landfill entry does not exist.");
        return landfillEntries[_id];
    }

    // Getter functions for the reports
    function getWeeklyReport(uint256 _id)
        public
        view
        returns (WeeklyReport memory)
    {
        require(_id < weeklyReportId, "Weekly report does not exist.");
        return weeklyReports[_id];
    }

    // Getter function to get all reports of a specific type
    function getAllReportsByType(string memory _reportType)
        public
        view
        returns (WeeklyReport[] memory)
    {
        uint256 count = 0;
        for (uint256 i = 1; i < weeklyReportId; i++) {
            if (
                keccak256(bytes(weeklyReports[i].reportType)) ==
                keccak256(bytes(_reportType))
            ) {
                count++;
            }
        }
        WeeklyReport[] memory reports = new WeeklyReport[](count);
        uint256 index = 0;
        for (uint256 i = 1; i < weeklyReportId; i++) {
            if (
                keccak256(bytes(weeklyReports[i].reportType)) ==
                keccak256(bytes(_reportType))
            ) {
                reports[index] = weeklyReports[i];
                index++;
            }
        }
        return reports;
    }


     // Getter function to get the role of a specific user by address
    function getUserRole(address _user) public view returns (UserRole) {
        if (userRoles[_user][UserRole.DistrictAdmin]) {
            return UserRole.DistrictAdmin;
        } else if (userRoles[_user][UserRole.RecyclableAdmin]) {
            return UserRole.RecyclableAdmin;
        } else if (userRoles[_user][UserRole.LandfillAdmin]) {
            return UserRole.LandfillAdmin;
        } else if (userRoles[_user][UserRole.User]) {
            return UserRole.User;
        } else {
            return UserRole.None;
        }
    }



}
