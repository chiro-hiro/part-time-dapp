pragma solidity 0.4.18;


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
    }

    //New job append
    event NewJob(uint256 indexed id,
    address creator,
    uint256 salary,
    uint256 timeOut);

    //An woker start working
    event TakeJob(
    uint256 indexed id,
    address indexed labor);

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
        require(msg.value > jobData[jobId].salary/10);
        _;
    }

    //Check is it a taked job
    modifier onlyValidJob(uint256 jobId) {
        require(jobData[jobId].end == 0);
        require(jobData[jobId].start == 0);
        _;
    }

    //Append new job to mapping
    function
    createJob (uint256 timeOut, bytes title, bytes description)
    public onlyHaveFund onlyValidTimeOut(timeOut) payable returns(uint256 jobId)
    {
        // Saving a little gas by create a temporary object
        Job memory newJob;

        // Assign jobId
        jobId = totalJob;
        
        newJob.id = jobId;
        newJob.id = timeOut;
        newJob.title = title;
        newJob.description = description; 
        newJob.salary = msg.value;
        newJob.creator = msg.sender;

        //Trigger event
        NewJob(jobId, msg.sender, msg.value, timeOut);

        // Append newJob to jobData
        jobData[totalJob++] = newJob;
    }

    //Take job
    function
    takeJob (uint256 jobId)
    public onlyValidMortgage(jobId) onlyValidId(jobId) onlyValidJob(jobId)
    {
        //Trigger event to log labor
        TakeJob(jobId, msg.sender);

        //Change working state
        jobData[jobId].start = block.timestamp;
    }

    //Veiw job data
    function
    viewJob(uint256 jobId)
    public onlyValidId(jobId) constant returns (
    uint256 id,
    address creator,
    uint256 salary,
    uint256 start,
    uint256 end,
    uint256 timeOut,
    bytes title,
    bytes description)
    {
        Job memory jobReader = jobData[jobId];
        return (jobReader.id,
        jobReader.creator,
        jobReader.salary,
        jobReader.start,
        jobReader.end,
        jobReader.timeOut,
        jobReader.title,
        jobReader.description);
    }
 
}
