var Partime = artifacts.require("./PartTime.sol");
var instancePartime;
var jobIndex = 0;

function createTx(from, to, value = 0, gas = 1000000, gasPrice = 20000000) {
    return {
        from: from,
        to: to,
        gas: gas,
        gasPrice: gasPrice,
        value: value
    };
}

function stringMe(data){
    return Buffer.from(data.substr(2), 'hex').toString();
}

async function showJobData(id){
    let fields = ['id', 'creator', 'salary', 'start', 'end', 'timeOut', 'title', 'description','labor'];
    let data = await instancePartime.jobData(id);
    console.log("        Job's details:");
    for(let i = 0; i < data.length; i++){
        if(i == 6 || i == 7){
            console.log("        ", fields[i] + ":", stringMe(data[i].valueOf()));
        }else{
            console.log("        ", fields[i] + ":", data[i].valueOf());
        }
    }
}

var creator, labor, anonymos;

contract('Partime', function (accounts) {

    it('should have 0 total part time job', async function () {
        instancePartime = await Partime.deployed().then(function (instance) {
            return instance;
        });
        //Alias
        creator = accounts[1];
        labor = accounts[2];
        anonymos = accounts[3];
        let totalJob = await instancePartime.totalJob();
        assert.equal(totalJob.valueOf(), 0);
    });

    it('creator should able to add new job', async function () {
        let timeStamp = web3.toBigNumber((((new Date()).getTime() / 1000)| 0) + 432000);
        //Create a partime job
        instancePartime.create(
            timeStamp,
            "This is title #" + jobIndex,
            "This is description #" + jobIndex,
            createTx(creator, instancePartime.address, web3.toWei('1', 'ether')));
        //Increase job count
        jobIndex++;
        let totalJob = await instancePartime.totalJob();
        await showJobData(totalJob.sub(1));
        assert.equal(totalJob.valueOf(), 1);
    });

    it('anonymous actor should not able to cancel created job', async function () {
        let totalJob = await instancePartime.totalJob();
        let error = false;
        try{
            await instancePartime.cancel(totalJob.sub(1), createTx(anonymos, instancePartime.address));
        }catch(e){
            error = true;
        }
        assert.equal(error, true);
    });

    it('creator should able to cancel his created job', async function () {
        let totalJob = await instancePartime.totalJob();
        await instancePartime.cancel(totalJob.sub(1), createTx(creator, instancePartime.address));
        await showJobData(totalJob.sub(1));
    });

    it('creator should able to add new job', async function () {
        let timeStamp = web3.toBigNumber((((new Date()).getTime() / 1000)| 0) + 432000);
        //Create a partime job
        instancePartime.create(
            timeStamp,
            "This is title #" + jobIndex,
            "This is description #" + jobIndex,
            createTx(creator, instancePartime.address, web3.toWei('1', 'ether')));
        //Increase job count
        jobIndex++;
        let totalJob = await instancePartime.totalJob();
        await showJobData(totalJob.sub(1));
        assert.equal(totalJob.valueOf(), 2);
    });

    it('labor should able to take available job', async function () {
        let totalJob = await instancePartime.totalJob();
        //Take a partime job
        instancePartime.take(totalJob.sub(1), createTx(labor, instancePartime.address, web3.toWei('0.1', 'ether')));
        let data = await instancePartime.jobData(totalJob.sub(1));
        await showJobData(totalJob.sub(1));
        assert.equal(data[8].valueOf(), labor)
    });

    it('anonymous actor should not able to mark job as done', async function () {
        let totalJob = await instancePartime.totalJob();
        let error = false;
        try {
            await instancePartime.finished(totalJob.sub(1), createTx(anonymos, instancePartime.address));    
        } catch (e) {
            error = true;
        }
        assert.equal(error, true);
    });

    it('anonymous actor should not able to mark job as failed', async function () {
        let totalJob = await instancePartime.totalJob();
        let error = false;
        try {
            await instancePartime.failed(totalJob.sub(1), createTx(anonymos, instancePartime.address));    
        } catch (e) {
            error = true;
        }
        assert.equal(error, true);
    });

    it('labor actor should able to mark job as failed', async function () {
        let totalJob = await instancePartime.totalJob();
        await instancePartime.failed(totalJob.sub(1), createTx(labor, instancePartime.address));
        let data = await instancePartime.jobData(totalJob.sub(1));
        await showJobData(totalJob.sub(1));
        assert.equal(data[8].valueOf(), '0x0000000000000000000000000000000000000000')
    });

    it('labor should able to take available job again', async function () {
        let totalJob = await instancePartime.totalJob();
        //Take a partime job
        instancePartime.take(totalJob.sub(1), createTx(labor, instancePartime.address, web3.toWei('0.1', 'ether')));
        let data = await instancePartime.jobData(totalJob.sub(1));
        await showJobData(totalJob.sub(1));
        assert.equal(data[8].valueOf(), labor)
    });

    it('labor actor should able to mark job as done', async function () {
        let totalJob = await instancePartime.totalJob();
        await instancePartime.finished(totalJob.sub(1), createTx(labor, instancePartime.address));
        let data = await instancePartime.jobData(totalJob.sub(1));
        await showJobData(totalJob.sub(1));
        assert.equal(data[3].toNumber() > 0, true);
        assert.equal(data[4].toNumber() > 0, true);
    });

    it('anonymous actor should not able to pay for labor', async function () {
        let totalJob = await instancePartime.totalJob();
        let error = false;
        try {
            await instancePartime.pay(totalJob.sub(1), createTx(anonymos, instancePartime.address));            
        } catch (e) {
            error = true;
        }
        assert.equal(error, true);
    });

    it('creator should able to pay for labor', async function () {
        let totalJob = await instancePartime.totalJob();
        await instancePartime.pay(totalJob.sub(1), createTx(creator, instancePartime.address));
        let data = await instancePartime.jobData(totalJob.sub(1));
        await showJobData(totalJob.sub(1));
        assert.equal(data[9].valueOf(), true);
    });
    
});