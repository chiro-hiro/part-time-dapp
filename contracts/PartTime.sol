pragma solidity ^0.4.23;


contract PartTime {
    
    //Job structure
    struct Job {
        uint256 id;
        address creator;
        uint256 salary;
        uint256 start;
        uint256 end;
        uint256 timeOut;
        bytes title;
        bytes description;
        address labor;
        bool done;
    }

    //We don't let any trapped in this contract
    function () public payable {
        revert();
    }

    //Empty constructor
    constructor () public {}

    //New job append
    event NewJob(uint256 indexed id, address creator, uint256 salary, uint256 timeOut);

    //An woker start working
    event TakeAJob( uint256 indexed id, address indexed labor);
    
    //Cancel created job
    event CancelCreatedJob(uint256 indexed id, address creator);

    //Job done event
    event Done(uint256 jobId, address indexed labor);

    //Job failed event
    event Failed(uint256 jobId, address indexed labor);

    //Paid
    event Paid(address indexed creator, address indexed labor, uint256 value);

    //Minium accept salary
    uint256 constant public MINIUM_SALARY = 0.1 ether;

    //The number of jobs
    uint256 public totalJob;

    //Mapped data
    mapping (uint256 => Job) public jobData;
    
    //Transaction must contant Ethereum
    modifier onlyHaveFund {
        require(msg.value > MINIUM_SALARY);
        _;
    }

    //Valid timeOut should be greater than 3 days
    modifier onlyValidTimeOut(uint256 timeOut) {
        require(timeOut > 3 days);
        _;
    }

    //Check valid job Id
    modifier onlyValidId(uint256 jobId) {
        require(jobId < totalJob);
        _;
    }

    //Mortgage should be greater than 1/10
    modifier onlyValidMortgage(uint256 jobId) {
        require(msg.value >= jobData[jobId].salary/10);
        _;
    }

    //Only job creator is accepted
    modifier onlyCreator(uint256 jobId) {
        require(jobData[jobId].creator == msg.sender);
        _;
    }

    //Only job labor is accepted
    modifier onlyLabor(uint256 jobId) {
        require(jobData[jobId].labor == msg.sender);
        _;
    }

    //Check is it a taked job
    modifier onlyAvailableJob(uint256 jobId) {
        require(jobData[jobId].end == 0);
        require(jobData[jobId].start == 0);
        _;
    }

    modifier onlyNotDone(uint256 jobId){
        require(jobData[jobId].done == false);
        _;
    }

    //Append new job to mapping
    function create(uint256 timeOut, bytes title, bytes description)
    public onlyHaveFund onlyValidTimeOut(timeOut) payable returns(uint256 jobId)
    {
        // Saving a little gas by create a temporary object
        Job memory newJob;

        // Assign jobId
        jobId = totalJob;
        
        newJob.id = jobId;
        newJob.timeOut = timeOut;
        newJob.title = title;
        newJob.description = description; 
        newJob.salary = msg.value;
        newJob.creator = msg.sender;

        // Append newJob to jobData
        jobData[totalJob] = newJob;
        totalJob++;
        //Trigger event
        emit NewJob(jobId, msg.sender, msg.value, timeOut);

        return jobId;
    }

    //Creator able to cancel his own jobs
    function cancel(uint256 jobId)
    public onlyCreator(jobId) onlyAvailableJob(jobId) onlyValidId(jobId) returns(bool)
    {
        //Job will become unavailable due to end isn't equal to 0
        jobData[jobId].end = block.timestamp;

        //Smart contract have to return mortgage
        jobData[jobId].creator.transfer(jobData[jobId].salary);

        emit CancelCreatedJob(jobId, msg.sender);

        return true;
    }

    //Take job
    function take(uint256 jobId)
    public payable onlyValidMortgage(jobId) onlyValidId(jobId) onlyAvailableJob(jobId) returns(bool)
    {

        //Change working state
        jobData[jobId].start = block.timestamp;
        jobData[jobId].labor = msg.sender;
        
        //Trigger event to log labor
        emit TakeAJob(jobId, msg.sender);

        return true;
    }

    //Labor had finished their job
    function finished(uint256 jobId)
    public onlyValidId(jobId) onlyLabor(jobId) returns(bool) {
        jobData[jobId].end = block.timestamp;
        emit Done(jobId, msg.sender);
        return true;
    }

    //Labor had failed their job
    function failed(uint256 jobId)
    public onlyValidId(jobId) onlyLabor(jobId) returns(bool) {
        //Reset job
        Job memory mJob = jobData[jobId];
        uint256 value = (mJob.salary/10)/2;
        mJob.start = 0;
        mJob.labor = 0;
        //Update data set
        jobData[jobId] = mJob;
        //Labor lost 1/2 their mortgage
        msg.sender.transfer(value);
        //Creator receive 1/2 labor's mortgage
        mJob.creator.transfer(value);
        emit Failed(jobId, msg.sender);
        return true;
    }

    //Creator pay money
    function pay(uint256 jobId)
    public onlyValidId(jobId) onlyCreator(jobId) onlyNotDone(jobId) returns(bool) {
        uint256 value;
        
        //Fund = salary + mortgage
        value = jobData[jobId].salary;
        value = value + (value/10);

        //Mark job ask done
        jobData[jobId].done = true;

        //Transfer fund and mortgage to labor
        jobData[jobId].labor.transfer(value);
        
        emit Paid(jobData[jobId].creator, jobData[jobId].labor, value);

        return true;
    }
 
}
