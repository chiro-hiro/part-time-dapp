var Partime = artifacts.require("./PartTime.sol");

function createTx(from, to, value = 0, gas = 1000000, gasPrice = 20000000) {
    return {
        from: from,
        to: to,
        gas: gas,
        gasPrice: gasPrice,
        value: value
    };
}

contract('Partime', function (accounts) {

    it('should have 0 total part time job', function () {
        return Partime.deployed().then(function (instance) {
            return instance.totalJob.call();
        }).then(function (totalJob) {
            assert.equal(totalJob.valueOf(), 0, 'Total job was not equal to 0');
        });
    });

    it('should able to add new job', function () {
        return Partime.deployed().then(function (instance) {
            return instance.createJob(((new Date()).getTime() / 1000 + 432000),
                "This is tittle",
                "This is description",
                createTx(accounts[0], instance.address, web3.toWei('1', 'ether')));
        }).then(function (totalJob) {
            assert.equal(typeof (totalJob.valueOf()), 'object', 'Transaction was not triggered success');
        });
    });

    it('should have total part time job geater than 0', function () {
        return Partime.deployed().then(function (instance) {
            return instance.totalJob.call();
        }).then(function (totalJob) {
            assert.equal(totalJob.valueOf() > 0, true, 'Total job was equal to 0' );
        });
    });

});