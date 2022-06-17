import { task, types } from 'hardhat/config';

task('change-owner', 'Changing owner')
  .addParam('name', 'Name of contract', undefined, types.string)
  .addParam('address', 'Address new owner', undefined, types.string)
  .addParam('contract', 'Contract address', undefined, types.string)
  //   HRE = Hardhat Runtime Environment
  .setAction(async (taskArgs, hre) => {
    const telephone = await hre.ethers.getContractAt(
      taskArgs.name,
      taskArgs.contract
    );
    telephone.changeOwner(taskArgs.address);

    // TELEPHONE 0x5fbdb2315678afecb367f032d93f642f64180aa3
    // MiddleManHack 0xe7f1725e7734ce288f8367e1bb143e90bb3f0512
  });

task('hack', 'Do middleMan hack')
  .addParam('name', 'Name of contract', undefined, types.string)
  .addParam('address', 'Address new owner', undefined, types.string)
  .addParam('contract', 'Contract address', undefined, types.string)
  //   HRE = Hardhat Runtime Environment
  .setAction(async (taskArgs, hre) => {
    console.log(taskArgs);

    // TELEPHONE 0x5fbdb2315678afecb367f032d93f642f64180aa3
    // MiddleManHack 0xe7f1725e7734ce288f8367e1bb143e90bb3f0512
  });
