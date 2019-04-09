pragma solidity ^0.5.0;

// ---------------------------------------------
// FileIdentityVerification.sol
// ---------------------------------------------
// Copyright (c) 2019 PLUSPLUS CO.,LTD.
// Released under the MIT license
// https://www.plusplus.jp/
// ---------------------------------------------

//
// File identity verification
//
contract FileIdentityVerification {

    struct FileIdentity {
        bytes32 fileId;

        bytes md5;
        bytes sha256;
        bytes sha512;

        address registrant;
        uint timestamp;
        uint isExist;
    }

    // Number of valid hashes
    uint public number_of_registrations;

    // Keep a list of hashes
    mapping(bytes32 => FileIdentity) private fileIdentityList;

    string private NO_DATA = 'Data does not exist';
    string private ALREADY_REGISTERED = 'It is already registered';
    string private NO_DELETE_AUTHORITY = 'You do not have permission to delete';

    // Events
    event FileHash(address indexed _from, bytes32 _fileId, bytes _md5, bytes _sha256, bytes _sha512, uint _timestamp);

    constructor() public {
        number_of_registrations = 0;
    }

    // @title Get file information
    function getFileIdentity(bytes32 fileId) public view
    returns (bytes32 _fileId, bytes memory _md5, bytes memory _sha256, bytes memory _sha512, address _registrant, uint _timestamp, uint _isExist){
        FileIdentity memory fi = fileIdentityList[fileId];
        return (fi.fileId, fi.md5, fi.sha256, fi.sha512, fi.registrant, fi.timestamp, fi.isExist);
    }

    // @title File existence check
    function isExist(bytes32 fileId) public view returns (bool) {
        if (fileIdentityList[fileId].isExist == 1) {
            // isExist == 1 is mean : exist
            return true;
        }
        else {
            // not exist
            return false;
        }
    }

    // @title Calculate file ID from file hash
    function getFileId(string memory _md5, string memory _sha256, string memory _sha512) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(bytes(_md5), bytes(_sha256), bytes(_sha512)));
    }

    // @title  Register file hash
    function registerFileHash(string memory _md5, string memory _sha256, string memory _sha512) public returns (bool) {

        bytes32 fileId = getFileId(_md5, _sha256, _sha512);

        require(isExist(fileId) == false, ALREADY_REGISTERED);

        uint ts = block.timestamp;

        fileIdentityList[fileId].isExist = 1;
        fileIdentityList[fileId].fileId = fileId;

        fileIdentityList[fileId].md5 = bytes(_md5);
        fileIdentityList[fileId].sha256 = bytes(_sha256);
        fileIdentityList[fileId].sha512 = bytes(_sha512);

        fileIdentityList[fileId].registrant = msg.sender;
        fileIdentityList[fileId].timestamp = ts;

        emit FileHash(msg.sender, fileId, bytes(_md5), bytes(_sha256), bytes(_sha512), ts);

        // Add actual registration number
        ++number_of_registrations;

        return true;
    }

}
