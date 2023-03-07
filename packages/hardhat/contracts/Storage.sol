// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract StructDefiner {
  struct MyStruct {
    uint256 someField;
    address someAddress;
    uint128 someOtherField;
    uint128 oneMoreField;
  }
}

contract Storage {
    StructDefiner.MyStruct[] internal myStructs;

    function createStruct(uint256 someField, address someAddress, uint128 someOtherField, uint128 oneMoreField) public {
        myStructs.push(StructDefiner.MyStruct(someField, someAddress, someOtherField, oneMoreField));
    }

    function get(uint _index) public view returns (uint256 someField, address someAddress, uint128 someOtherField, uint128 oneMoreField) {
        StructDefiner.MyStruct storage myStruct = myStructs[_index];
        return (myStruct.someField, myStruct.someAddress, myStruct.someOtherField, myStruct.oneMoreField);
    }

    function getStructByIdx(uint256 idx) public view returns (StructDefiner.MyStruct memory) {
        require(idx < myStructs.length, "Struct with that index does not exist.");

        StructDefiner.MyStruct memory myStruct;
        assembly {
            // Calculate the memory offset of the struct at the given index.
            let offset := mul(idx, 32) // Each struct occupies 32 bytes of memory
            let structPtr := add(add(myStructs.slot, 32), offset)

            // Load the MyStruct from memory into the myStruct variable.
            myStruct := mload(structPtr)
        }

        return myStruct;
    }

    function fromBytes(bytes memory data) public pure returns (StructDefiner.MyStruct memory myStruct) {
        require(data.length >= 32, "Invalid input data.");
        assembly {
            // Load the data into memory.
            let ptr := add(data, 32)
            let dataLength := mload(data)
            let endPtr := add(ptr, dataLength)

            // Load the fields of the MyStruct struct from memory.
            myStruct := mload(0x40)
            mstore(add(myStruct, 0), mload(ptr))            // myStruct.someField
            mstore(add(myStruct, 32), mload(add(ptr, 32)))  // myStruct.someAddress
            mstore(add(myStruct, 64), mload(add(ptr, 64)))  // myStruct.someOtherField
            mstore(add(myStruct, 96), mload(add(ptr, 96)))  // myStruct.oneMoreField

            // Resize the myStruct variable to the exact size needed.
            let size := 96
            switch iszero(eq(mload(add(myStruct, 32)), 0))
            case 1 {
                size := sub(size, 12)
            }
            case 0 {
                size := sub(size, 20)
            }
            // In Solidity, free memory is kept track of using the special memory slot located at address 0x40
            mstore(0x40, add(myStruct, add(size, 32))) // In Solidity, free memory is kept track of using the special memory slot located at address 0x40
        }
        return myStruct;
    }


    function toBytes(StructDefiner.MyStruct memory myStruct) public pure returns (bytes memory) {
        bytes memory buffer = new bytes(64);
        assembly {
            // Store the fields of the MyStruct struct in memory.
            mstore(add(buffer, 0), mload(add(myStruct, 0)))
            mstore(add(buffer, 32), mload(add(myStruct, 32)))
            mstore(add(buffer, 64), mload(add(myStruct, 64)))
            mstore(add(buffer, 96), mload(add(myStruct, 96)))

            // Resize the buffer to the exact size needed.
            let size := 96
            switch iszero(eq(mload(add(myStruct, 32)), 0))
            case 1 {
                size := sub(size, 12)
            }
            case 0 {
                size := sub(size, 20)
            }
            buffer := mload(0x40) // 0x40 represents the start of the free memory pointer in the EVM memory
            mstore(buffer, size)
            mstore(add(buffer, 32), add(size, 32))
            mstore(0x40, add(buffer, add(size, 64)))
        }
        return buffer;
    }
}

contract Controller {
    Storage internal storages;

    constructor(address _storage) {
        storages = Storage(_storage);
    }

    function getStruct(uint256 idx) public view returns (StructDefiner.MyStruct memory myStruct) {
        bytes memory _myStructBytes = storages.toBytes(storages.getStructByIdx(idx));
        myStruct = storages.fromBytes(_myStructBytes);
    }

    function getStructAsm(uint256 idx) public view returns (StructDefiner.MyStruct memory myStruct) {
        bytes memory _myStructBytes = storages.toBytes(storages.getStructByIdx(idx));
        assembly {
            let ptr := add(_myStructBytes, 32)
            myStruct := mload(ptr)
        }   
    }
}
