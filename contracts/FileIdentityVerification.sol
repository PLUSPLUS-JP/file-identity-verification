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

    // Cumulative number of hashes registered
    // ハッシュを登録した累計回数
    uint public number_of_hashes_registered;

    // Number of valid hashes
    // 有効なハッシュの数
    uint public number_of_valid_hashes;

    // Keep a list of hashes
    // ハッシュの一覧を保持する
    mapping(bytes32 => FileIdentity) private fileIdentityList;

    string private NO_DATA = 'Data does not exist';
    string private ALREADY_REGISTERED = 'It is already registered';
    string private NO_DELETE_AUTHORITY = 'You do not have permission to delete';

    // Events
    event FileHash(address indexed _from, bytes32 _fileId, bytes _md5, bytes _sha256, bytes _sha512, uint _timestamp);

    constructor() public {
        number_of_hashes_registered = 0;
        number_of_valid_hashes = 0;
    }

    // ファイル情報を照会
    function getFileIdentity(bytes32 fileId) public view
    returns (bytes32 _fileId, bytes memory _md5, bytes memory _sha256, bytes memory _sha512, address _registrant, uint _timestamp, uint _isExist){
        FileIdentity memory fi = fileIdentityList[fileId];
        return (fi.fileId, fi.md5, fi.sha256, fi.sha512, fi.registrant, fi.timestamp, fi.isExist);
    }

    // File existence check
    // ファイルの存在チェック
    function isExist(bytes32 fileId) public view returns (bool) {
        if (fileIdentityList[fileId].isExist == 1) {
            // exist
            return true;
        }
        else {
            // not exist
            return false;
        }
    }

    function getFileId(string memory _md5, string memory _sha256, string memory _sha512) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(bytes(_md5), bytes(_sha256), bytes(_sha512)));
    }

    // Register file hash
    // ファイルハッシュを登録する
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
        // 実際の登録数
        ++number_of_valid_hashes;

        // Add cumulative number
        // 累計数
        ++number_of_hashes_registered;

        return true;
    }

}
