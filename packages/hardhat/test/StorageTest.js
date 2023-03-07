const { expect } = require('chai');

describe("Storage contract", function() {
  let storage;
  let controller;

  before(async function() {
    // Deploy contracts
    const Storage = await ethers.getContractFactory("Storage");
    storage = await Storage.deploy();
    await storage.deployed();

    const Controller = await ethers.getContractFactory("Controller");
    controller = await Controller.deploy(storage.address);
    await controller.deployed();
  });


  

  it("should get a struct by index", async function() {
    // Create a new struct and store it in the contract
    const newStruct = {
      someField: 123,
      someAddress: ethers.constants.AddressZero,
      someOtherField: 456,
      oneMoreField: 789,
    };
    await storage.myStructs.push(newStruct);

    // Get the struct using the getStructByIdx function
    const structFromContract = await storage.getStructByIdx(0);

    // Check that the returned struct is equal to the one we stored
    expect(structFromContract.someField).to.equal(newStruct.someField);
    expect(structFromContract.someAddress).to.equal(newStruct.someAddress);
    expect(structFromContract.someOtherField).to.equal(newStruct.someOtherField);
    expect(structFromContract.oneMoreField).to.equal(newStruct.oneMoreField);

    // Get the struct using the getStruct function in the controller contract
    const structFromController = await controller.getStruct(0);

    // Check that the returned struct is equal to the one we stored
    expect(structFromController.someField).to.equal(newStruct.someField);
    expect(structFromController.someAddress).to.equal(newStruct.someAddress);
    expect(structFromController.someOtherField).to.equal(newStruct.someOtherField);
    expect(structFromController.oneMoreField).to.equal(newStruct.oneMoreField);
  });
});
