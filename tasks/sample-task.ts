import { task, types } from 'hardhat/config';

task('change-owner', 'Changing owner')
  .addParam('name', 'Contract name', undefined, types.string)
  .addParam('address', 'Address new owner', undefined, types.string)
  .addParam('contract', 'Contract address', undefined, types.string)

  //   HRE = Hardhat Runtime Environment
  .setAction(async (taskArgs, hre) => {
    const telephone = await hre.ethers.getContractAt(
      taskArgs.name,
      taskArgs.contract
    );

    await telephone.changeOwner(taskArgs.contract);
  });

task('owner', 'Get owner from <contract>')
  .addParam('name', 'Contract name', undefined, types.string)
  .addParam('contract', 'Contract address', undefined, types.string)

  .setAction(async (taskArgs, { ethers }) => {
    const telephone = await ethers.getContractAt(
      taskArgs.name,
      taskArgs.contract
    );

    console.log(await telephone.owner());
  });

task('hack', 'Do middleMan hack')
  .addParam('name', 'Contract name', undefined, types.string)
  .addParam('contract', 'Contract address', undefined, types.string)
  .addParam('prey', 'Contract address for hack')
  .addParam('newowner', 'Contract address for hack')

  .setAction(async (taskArgs, { ethers }) => {
    const hackContract = await ethers.getContractAt(
      taskArgs.name,
      taskArgs.contract
    );

    await hackContract.hack(taskArgs.prey, taskArgs.newowner);
  });
