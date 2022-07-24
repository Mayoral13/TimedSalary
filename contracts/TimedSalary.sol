pragma solidity ^0.8.11;
import "./SafeMath.sol";
import "./Ownable.sol";
contract TimedSalary is Ownable{
    using SafeMath for uint;
    uint private cooldown;
    uint private timePaid = block.timePaid;
    mapping(address => uint)balances;
    mapping(address => bool)isWorker;
    mapping(address => uint)balanceRecieved;
    address[]Workers;
    bool Paid;

    function RecieveETH()external payable returns(bool success){
     require(Workers.length != 0,"Add some workers first");
     require(cooldown != 0,"Set a Cooldown First");
     require(Paid == false,"Salaries have not been paid yet");
     require(address(this).balance != 0,"Deposit Salaries First");
     Paid = false;
    if(block.timestamp >= timePaid.add(cooldown)){
     for(uint i = 0; i<Workers.length;i++){
     balances[Workers[i]] = msg.value.div(Workers.length);
     balanceRecieved[Workers[i]] = balanceRecieved[Workers[i]].add(balances[Workers[i]]);
     balances[Workers[i]] = 0;
     payable(Workers[i]).send(balances[Workers[i]]);       
     } 
    }
    Paid = true;
    return true;
    }

    function SetCooldown(uint _value)external onlyOwner returns(bool success){
        require(_value != 0,"Cooldown cannot be 0");
        cooldown = _value;
        return true;
    }

    function AddWorkers(address _worker)external onlyOwner returns(bool success){
        require(Paid == false,"Pay Salaries First");
        require(isWorker[_worker] == false,"Already a worker");
        Workers.push(_worker);
        isWorker[_worker] = true;
        return true;
    }
    function RemoveWorker(address _worker)external onlyOwner returns(bool success){
        require(Paid == false,"Pay Salaries First");
        require(isWorker[_worker] == true,"Must be a worker");
        for(uint i = 0; i<= Workers.length;i++){
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

    function ETHBalance()public view returns(uint){
        return msg.sender.balance;
    }

    function ETHRecieved()public view returns(uint){
        return balanceRecieved[msg.sender];
    }
    function ContractBalance()public view returns(uint){
        return address(this).balance;
    }
    function ShowWorkers()public view returns(address[] memory){
        return Workers;
    }
    function SalaryPaid()public view returns(bool){
        return Paid;
    }
}