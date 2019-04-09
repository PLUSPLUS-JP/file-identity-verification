const fs = require('fs');
const FileIdentityVerification = artifacts.require('./FileIdentityVerification.sol');

module.exports = (deployer) => {
    deployer.deploy(FileIdentityVerification).then(() => {
        // Save ABI to file
        fs.mkdirSync('deploy/abi/', { recursive: true });
        fs.writeFileSync('deploy/abi/FileIdentityVerification.json', JSON.stringify(FileIdentityVerification.abi), { flag: 'w' });
    });
};
