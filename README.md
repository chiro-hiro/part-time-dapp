# Part Time dApp

Establish peer-to-peer transactions in part time jobs.

## Installation

This project is required NodeJS 8.x.x LTS.

## Dependencies Packages

Microsoft build tools:
```
$ npm i -g -p windows-build-tools
```

Install development packages:
```
$ npm i -g ganache-cli truffle mkinterface
```

## Testing

Open terminal at the root directory of project:
```
$ ganache-cli
```
then in another terminal:
```
$ truffle migrate --reset && truffle test
```

## Build interface

At the root folder of project:
```
$ truffle compile && mkinterface
```