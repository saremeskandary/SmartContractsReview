const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Storage', function () {
  let StructDefiner;
  let Storage;
  let Controller;
  let DStructDefiner;
  let DStorage;
  let DController;

  // quick fix to let gas reporter fetch data from gas station & coinmarketcap
  before((done) => {
    setTimeout(done, 2000);
  });
 
  describe("deployment", async function () {
    it("Should deploy StructDefiner", async function () {
      StructDefiner = await ethers.getContractFactory("StructDefiner");
      DStructDefiner = await StructDefiner.deploy();
    });
    it("Should deploy Storage", async function () {
      Storage = await ethers.getContractFactory("Storage");
      DStorage = await Storage.deploy();
    });
    it("Should deploy Controller", async function () {
      Controller = await ethers.getContractFactory("Controller");
      console.log(`storage address: ${DStorage.address}`);
      DController = await Controller.deploy(DStorage.address);
    });

    console.log(`DStorage is: ${DStorage}`);
    it('should create a struct', async function () {
      const someField = 123;
      const someAddress = '0x000000000000000000000000000000000000abcd';
      const someOtherField = 456;
      const oneMoreField = 789;


      await DStorage.createStruct(
        someField,
        someAddress,
        someOtherField,
        oneMoreField
      );

      const myStruct = await DController.getStruct(0);
      console.log(`myStruct ${myStruct}`);
      expect(myStruct.someField).to.equal(someField);
      expect(myStruct.someAddress).to.equal(someAddress);
      expect(myStruct.someOtherField).to.equal(someOtherField);
      expect(myStruct.oneMoreField).to.equal(oneMoreField);
    });

    // it('should retrieve a struct', async function () {
    //   const someField = 123;
    //   const someAddress = '0x000000000000000000000000000000000000abcd';
    //   const someOtherField = 456;
    //   const oneMoreField = 789;

    //   await DController.createStruct(
    //     someField,
    //     someAddress,
    //     someOtherField,
    //     oneMoreField
    //   );

    //   const myStructBytes = await DController.getStructBytes(0);
    //   const myStruct = await DController.getStructFromBytes(myStructBytes);
    //   expect(myStruct.someField).to.equal(someField);
    //   expect(myStruct.someAddress).to.equal(someAddress);
    //   expect(myStruct.someOtherField).to.equal(someOtherField);
    //   expect(myStruct.oneMoreField).to.equal(oneMoreField);
    // });
  })
});

