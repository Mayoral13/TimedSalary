pragma solidity ^0.8.11;
import "./SafeMath.sol";
import "./Ownable.sol";
contract TimedSalary is Ownable{
    using SafeMath for uint;
    uint private cooldown;
    uint private timePaid;
    mapping(address => uint)balances;
    mapping(address => bool)isWorker;
    mapping(address => bool)isPaid;
    mapping(address => uint)balanceRecieved;
    address[]Workers;
    bool Paid;
    

    function RecieveETH()external payable returns(bool success){
     require(Workers.length != 0,"Add some workers first");
     require(Paid == false,"Pay Salaries First");
     for(uint i = 0; i<Workers.length;i++){
      balances[Workers[i]] = msg.value.div(Workers.length);
      balanceRecieved[Workers[i]] = balanceRecieved[Workers[i]].add(balances[Workers[i]]);
     Paid = true;
     }
     return true;
    }
    function SetCooldown(uint _value)external onlyOwner returns(bool success){
        require(_value != 0,"Cooldown cannot be 0");
        _value = cooldown;
    }

    function AddWorkers(address _worker)external onlyOwner returns(bool success){
        require(isWorker[_worker] == false,"Already a worker");
        Workers.push(_worker);
        isWorker[_worker] = true;
        return true;
    }
    function RemoveWorker(address _worker)external onlyOwner returns(bool success){
        require(isWorker[_worker] == true,"Must be a worker");
        for(uint i = 0; i<Workers.length;i++){
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
    function Salary(address _worker)public view returns(uint){
        return balances[_worker];
    }

    function PaySalary()external onlyOwner returns(bool success){
        require(Paid == true,"Deposit First");
        require(cooldown != 0,"Set Cooldown First");
        if(block.timestamp >= timePaid + cooldown){
            for(uint i = 0; i<Workers.length;i++){
                balanceRecieved[Workers[i]] = balanceRecieved[Workers[i]].add(balances[Workers[i]]);
                balances[Workers[i]] = 0;
                Paid = false;
                payable(Workers[i]).send(balances[Workers[i]]);
                isPaid[Workers[i]] = true;
                timePaid = block.timestamp;
        }
        return true;
    }
    }
    function isSalaryPaid()public view returns(bool){
        return isPaid[msg.sender];
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
}