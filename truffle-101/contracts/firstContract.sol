pragma solidity ^0.5.0;


contract firstContract {
  constructor() public {
  }
  function hello () public pure returns(string memory) {
  	// the only way to update the string is to make it
  	// to a storage var or create a new contract
  	return "Hello Laure";  	
  }
  
}
