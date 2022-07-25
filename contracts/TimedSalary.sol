pragma solidity ^0.8.11;
import "./SafeMath.sol";
import "./Ownable.sol";
contract TimedSalary is Ownable{
    //USING THE SAFEMATH LIBRARY FOR ARITHMETIC OPERATIONS
    using SafeMath for uint;
    //UINT FOR COOLDOWN
    uint private cooldown;
    //UINT TO REVEAL PAYMENT OF LAST SALARY
    uint private timePaid;
    //AN ARRAY TO STORE EMPLOYEES
    address[]Workers;
    //A BOOLEAN TO KEEP TRACK OF COOLDOWN
    bool private cooldownSet;
    //A BOOLEAN TO KEEP TRACK OF SALARY PAYMENT
    bool private Paid;
    //A MAPPING TO KEEP SHOW IF AN ADDRESS IS A WORKER
    mapping(address => bool)isWorker;
    //A MAPPING TO KEEP TRACK OF SALARIES RECIEVED BY EACH ADDRESS
    mapping(address => uint)Recieved;

    //A FUNCTION TO PAY SALARIES ONLY THE OWNER CAN CALL IT
    function PaySalaries()external onlyOwner payable returns(bool success){
     require(Workers.length != 0,"Add some workers first");
     require(block.timestamp > cooldown,"Wait till cooldown is reached");
     require(cooldownSet == true,"Set cooldown first");
     require(Paid == false,"Wait till Salaries have been Paid");
     require(msg.value != 0,"Dont be so stingy");
     for(uint i = 0; i<Workers.length;i++){
     Recieved[Workers[i]] = Recieved[Workers[i]].add((msg.value).div(Workers.length)); 
     payable(Workers[i]).send(msg.value.div(Workers.length));
    }
    timePaid = block.timestamp;
    Paid = true;
    cooldownSet = false;
    return true;
    }
    
    //FUNCTION TO SET COOLDOWN THE TIME IN WHICH THE CONTRACT WILL ONLY BE ACCEPTING ETHER FOR SALARY PAYMENT
    //ONLY OWNER CAN CALL IT
    function SetCooldown(uint _value)external onlyOwner returns(bool success){
        require(_value != 0,"Cooldown cannot be 0");
        require(cooldownSet == false,"Wait till cooldown is reached");
        cooldown = block.timestamp.add(_value);
        cooldownSet = true;
        Paid = false;
        return true;
    }
    
    //FUNCTION TO ADD WORKERS ONLY OWNER CAN CALL IT 
    function AddWorkers(address _worker)external onlyOwner returns(bool success){
        require(cooldownSet == false,"Wait till salaries have been paid");
        require(isWorker[_worker] == false,"Already a worker");
        Workers.push(_worker);
        isWorker[_worker] = true;
        return true;
    }
    //FUNCTION TO REMOVE WORKER ONLY OWNER CAN CALL IT TOO
    function RemoveWorker(address _worker)external onlyOwner returns(bool success){
        require(isWorker[_worker] == true,"Must be a worker");
        require(cooldownSet == false,"Wait till cooldown is reached");
        for(uint i = 0; i< Workers.length;i++){
            if(_worker == Workers[i]){
                Workers.pop();
                isWorker[_worker] = false;
            }
        }
        return true;
    }
    //FUNCTION TO CHECK IF ADDRESS IS A WORKER
    function CheckIfWorker(address _worker)public view returns(bool){
        return isWorker[_worker];
    }
    //FUNCTION TO REVEAL LAST TIME SALARY WAS PAID
    function TimeLastPaid()public view returns(uint){
        return timePaid;
    }
    //FUNCTION TO CHECK IF SALARIES HAVE BEEN PAID
    function SalariesPaid()public view returns(bool success){
        return Paid;
    }
    //FUNCTION TO CHECK HOW MUCH SALARIES A WORKER HAS RECIEVED
    function SalariesRecieved(address _user)public view returns(uint){
        require(CheckIfWorker(_user) == true,"User not a worker");
        return Recieved[_user];
    }
    //FUNCTION TO CHECK CONTRACT BALANCE
    function ContractBalance()public view returns(uint){
        return address(this).balance;
    }
    //FUNCTION TO SHOW ALL WORKERS
    function ShowWorkers()public view returns(address[] memory){
        return Workers;
    }
}