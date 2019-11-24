Santa Barbara Blockchain Summit (SBBS)
===
UCSB, Nov 23 2019
sbbs.site

Truffle workshop (Part I), Cruz Molina, Truffle
---

### Vocabulary and generalities
Two types of account:
- EOA: Externally Owned Account (private / public key)
- Contract account (public key, owned by EOA, can contain state and code)

Blocks:
- genesis block = first block, no parent
- one block can contain multiple transactions, depending on size of those
- bloc number = 1 + parent block number
- more doc and info on etherscan.io

Smart contract:
  - code deployed

### Truffle suite

Tools: Truffle CLI, Ganache, Drizzle

Get started:

Requirements: `npm` and `nodejs`
```
sudo apt-get install nodejs nodejs-dev
sudo apt-get install npm
npm -v
```

Install truffle:
```
sudo npm install -g truffle
```

First project helloWorld:
```
mkdir mydir ; cd mydir
truffle init
truffle create contract firstContract
```

Add a function in our brand new contract:
```
function hello () public pure returns(string memory) {
  	// the only way to update the string is to make it
  	// to a storage var or create a new contract
  	return "Hello World";
}
```
and deploy these changes:
```
truffle compile
truffle develop // opens the develop console
```
once in the develop consol, we deploy our changes:
```
migrate // this runs the initial_migration script, updates the state of the contract (from the migration folder, in numerical order)
```
- create new migration script for our new contract, migrate
- let's interact with contract instances from within the console
```
	let instance = await firstContract.deployed()
	instance.hello()
```
If changes to contract (example the "Hello World" --> "Hello Laure"), we need to `migrate --reset`. A simple `migrate` will only migrate new contracts but not account for changes in existing contracts.

`.exit` exits the develop console, cleans the slate.

Experimenting with box and drizzle:
```
mkdir truffle-drizzle-box; cd truffle-drizzle-box
truffle unbox drizzle
truffle develop
```
Once in the develop console: migrate the pre-existing contracts with `migrate`.

In a different terminal, start a DApp:
```
cd truffle-drizzle-box/app
npm run start
```
This opens a browser http://localhost:3000/ with an example

`npm i @truffle/hdwallet-provider`
and add in truffle-config.js:
```
const HDWalletProvider = require
const mnemonic = "" // get mnemonic from goerli metamask account created
```
and
```
ropsten: {
	provider: () => new NetworkProvider(mnemonic, "https://goerli.infura.io/v3/?????")
	network_id: "5"
}
```
use infura.io -> runs node for you


drizzle adheres to the blockchain and listens for changes, the dev doesn't have to worry about reflecting those changes anymore.




Truffle workshop (Part II), Kseniya Lifanova, Upstate Interactive and DAppladies
---

slides: dappladies.netlify.com/sbbs-workshop

Smart contracts: applications that can be deployed on BC, based on HL languages like `Solidity`, compiled into EVM bytecode

Code encapsulated in contract objects: `contract MyContract`, all vars and fucntions belong to that contract BUT state variables are stored in contract storage (take space on the BC)

We can use `mapping`, a key-value store system:
```
mapping (address => uint) public accountBalance;
mapping (uint => string) userIdToName;
mapping (address => bool) voted;
```

Tokens are built ontop on BC and are a representation on anything on BC (shares in a company, virtual pet...). ETH is the currency, it is in the blockchain.
- fungibile tokens: equivalent and interchangeable (how many do you have?)
- nongunfibigle tokens: contain unique characteristics, no two are the same (which one do you have?)

Sending tokens means “calling a function on a smart contract that someone wrote and deployed”.

Creating token: using a token contract, a sub-type of a smart contract:
- mappings from user addresses to their balance
- there are standards to create tokens (base contract + build ontop): ERC20 for fungible, ERC721 for nonfungible
- there are subtypes, eg ERC20Capped for capped tokens. You can accumulate properties by having a contract file for each property -- they will all get migrated after.
https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts --> good place for standard smart contracts

Useful functions on ERC20: `totalSupply`, `balanceOf`, `transfer`. Other functions are for involving a third party, eg selling on a platform: `allowance`, `approve`, `transferFrom`. You can `mint` and `burn` tokens (an application of burning tokens could be in a voting scheme, where each token is a vote and gets burnt when used).

### Practical: build a token

Create a dir and init a truffle project
```
mkdir token-workshop; cd token-workshop
npm init
truffle init
```

Prereq: OpenZeppelin
```
npm install @openzeppelin/contracts
```

Creating contracts
```
truffle create contract SBToken
truffle create contract AnimalToken
```

SBToken will be a fungible token: we use the ERC20 token standards and set an initial supply amount in the `SBToken.sol` contract file:
```
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";

contract SBToken is ERC20, ERC20Detailed {
  constructor(uint256 initialSupply) ERC20Detailed("SBToken", "SBT", 18 ) public {
    _mint(msg.sender, initialSupply);
  }
}
```

We then write a migration script to SBToken as `2_deploy_contracts.js`
```
const SBToken = artifacts.require("SBToken");

module.exports = function(deployer) {
  deployer.deploy(SBToken, 1000);
};
```

We go ahead and define our contract for AnimalToken:
```
import "@openzeppelin/contracts/token/ERC721/ERC721Full.sol";
import "@openzeppelin/contracts/drafts/Counters.sol";

contract AnimalToken is ERC721Full {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721Full("AnimalToken", "AMT") public {
    }

    function createToken(string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();

        uint256 animalId = _tokenIds.current();
        _mint(msg.sender, animalId);
        _setTokenURI(animalId, tokenURI);

        return animalId;
    }
}
```
and update our migration script:
```
const AnimalToken = artifacts.require("AnimalToken");
deployer.deploy(AnimalToken);
```

We can now compile, migrate (deploy) and interact with our tokens:
```
truffle compile
truffle develop
```
note: Account (0) address is the default address, given by `truffle develop`


In the develop console, let's check our SBToken
```
migrate
let instance = await SBToken.deployed()
instance
let supply = await instance.totalSupply()
supply.toNumber()
let balance_owner = await instance.balanceOf(accounts[0])
let balance_1 = await instance.balanceOf(accounts[0])
balance_owner.toNumber() // returns totalsupply = 1000
balance_1.toNumber() // this user has no token, returns 0 
```
See https://dappladies.netlify.com/sbbs-workshop/#/26 to send tokens

Now let's check our AnimalToken:
```
let animal = await AnimalToken.deployed()
await animal.createToken("https://static.boredpanda.com/blog/wp-content/uuuploads/cute-baby-animals/cute-baby-animals-10.jpg")
animal.ownerOf(1)
web3.eth.getAccounts()
animal.tokenURI(1)
await instance.createToken("https://url.jpg", {from: accounts[1]}) // create another token for another user
let totalAnimal = await instance_animal.totalSupply()
totalAnimal.toNumber() // 2, there are 2 tokens that have been created in total
```

note: for fun, check https://www.cryptokitties.co/
an example of using the blockchain: leasing vessels, each vessel is a token and you can lease it by sending the token to leassee

note on gas fees:
Keep in mind that your actual transaction fee will almost always be lower than the potential maximum – great! Once a miner executes your transaction, you keep whatever ether is left over from your gas limit. But if your gas limit is too low and the miner maxes out, your transaction will get cancelled and you’ll still have to pay the max fee – not so great. So make sure to choose a gas limit with enough room to guarantee your transaction goes through. Remember, MetaMask will always suggest the exact amount of gas to use so there’s no need to adjust.  (source: https://guide.cryptokitties.co/guide/gas?)