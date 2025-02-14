const path = require("path");
const solc = require("solc");
const fs = require('fs-extra')


const buildPath = path.resolve(__dirname, 'build')
fs.removeSync(buildPath)


// eslint-disable-next-line no-undef
const campaignPath = path.resolve(__dirname, "contracts", "Campaign.sol");
const source = fs.readFileSync(campaignPath, "utf8");

const input = {
    language: 'Solidity',
    sources: {
        'Campaign.sol': {
            content: source
        }
    },
    settings: {
        outputSelection: {
            '*': {
                '*': ['*'],
            }
        }
    }
}

const output = JSON.parse(solc.compile(JSON.stringify(input))).contracts['Campaign.sol'];
console.log(output)
fs.ensureDirSync(buildPath)

for (let contract in output) {
    fs.outputJsonSync(
        path.resolve(buildPath, contract.replace(":", "") + ".json"),
        output[contract]
    )
}


