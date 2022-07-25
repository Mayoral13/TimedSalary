pragma solidity ^0.8.11;
import "./SafeMath.sol";
import "./Ownable.sol";
contract TimedSalary is Ownable{
    using SafeMath for uint;
    uint private cooldown;
    uint private timePaid;
    address[]Workers;
    bool private cooldownSet;
    bool private Paid;
    mapping(address => bool)isWorker;
    mapping(address => uint)Recieved;

    function PaySalaries()external onlyOwner payable returns(bool success){
     require(Workers.length != 0,"Add some workers first");
     require(block.timestamp > cooldown,"Wait till cooldown is reached");
     require(cooldownSet == true,"Set cooldown first");
     require(Paid == false,"Wait till Salaries have been Paid");
     require(msg.value != 0,"Dont be so stingy");
     for(uint i = 0; i<Workers.length;i++){
     Recieved[Workers[i]] = Recieved[Workers[i]].add((msg.value).div(Workers.length)); 
     payable(Workers[i]).transfer(msg.value.div(Workers.length));
    }
    timePaid = block.timestamp;
    Paid = true;
    cooldownSet = false;
    return true;
    }

    function SetCooldown(uint _value)external onlyOwner returns(bool success){
        require(_value != 0,"Cooldown cannot be 0");
        require(cooldownSet == false,"Wait till cooldown is reached");
        cooldown = block.timestamp.add(_value);
        cooldownSet = true;
        Paid = false;
        return true;
    }

    function AddWorkers(address _worker)external onlyOwner returns(bool success){
        require(cooldownSet == false,"Wait till salaries have been paid");
        require(isWorker[_worker] == false,"Already a worker");
        Workers.push(_worker);
        isWorker[_worker] = true;
        return true;
    }
    function RemoveWorker(address _worker)external onlyOwner returns(bool success){
        require(isWorker[_worker] == true,"Must be a worker");
        require(cooldownSet == false,"Wait till cooldown is reached");
        for(uint i = 0; i< Workers.length;i++){
            if(_worker == Workers[i]){
                Workers.pop();
                Workers.length-1;
                isWorker[_worker] = false;
            }
        }
        return true;
    }
    function CheckIfWorker(address _worker)public view returns(bool){
        return isWorker[_worker];
    }
    function TimeLastPaid()public view returns(uint){
        return timePaid;
    }
    function SalariesPaid()public view returns(bool success){
        return Paid;
    }
    function SalariesRecieved(address _user)public view returns(uint){
        require(CheckIfWorker(_user) == true,"User not a worker");
        return Recieved[_user];
    }
    function ContractBalance()public view returns(uint){
        return address(this).balance;
    }
    function ShowWorkers()public view returns(address[] memory){
        return Workers;
    }
}