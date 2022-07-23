const salary = artifacts.require("TimedSalary");
module.exports = function (deployer) {
    deployer.deploy(salary);
  };
  