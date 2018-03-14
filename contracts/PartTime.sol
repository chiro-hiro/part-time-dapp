pragma solidity ^0.4.17;

contract PartTime {
  
  struct Job {
    uint256 id;
    address creator;
    uint256 salary;
    bytes title;
    bytes description;
  }

  uint256 totalJob;

  mapping (uint256 => Job) public jobData;
  

  function createJob(uint256 salary, bytes title, bytes description)
  returns(uint256 jobId)
  {
    // Saving a little gas by create a temporary object
    Job memory newJob;

    // Assign jobId
    jobId = totalJob;

    newJob.title = title;
    newJob.description = description;
    newJob.salary = salary;
    newJob.creator = msg.sender;

    // Append newJob to jobData
    jobData[totalJob++] = newJob;
  }
 
}
