pragma solidity ^0.4.23;

contract PartTimeInterface {
    //Events
    event NewJob(uint256 indexed id, address creator, uint256 salary, uint256 timeOut);
    event TakeAJob(uint256 indexed id, address indexed labor);
    event CancelCreatedJob(uint256 indexed id, address creator);
    event Done(uint256 jobId, address indexed labor);
    event Failed(uint256 jobId, address indexed labor);
    event Paid(address indexed creator, address indexed labor, uint256 value);
    //Public methods
    function jobData(uint256 ) public constant returns (uint256 id, address creator, uint256 salary, uint256 start, uint256 end, uint256 timeOut, bytes title, bytes description, address labor, bool done);
    function MINIUM_SALARY() public constant returns (uint256);
    function totalJob() public constant returns (uint256);
    function create(uint256 timeOut, bytes title, bytes description) public payable returns (uint256 jobId);
    function cancel(uint256 jobId) public returns (bool);
    function take(uint256 jobId) public payable returns (bool);
    function finished(uint256 jobId) public returns (bool);
    function failed(uint256 jobId) public returns (bool);
    function pay(uint256 jobId) public returns (bool);
}