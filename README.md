# Cucumber-cf
Cucumber implementation in CFML

# Installing and Running the Tests

To run tests, you'll need [CommandBox](https://www.ortussolutions.com/products/commandbox) installed.

Then run `box install` once to install the dependencies (TestBox is the only one currently).

Then start a CFML server via CommandBox:

`box start`

This will start Lucee5 on port 8800 and open a browser, running the Testbox runner. (__Note__: you can change the CFML engine and port in `server.json` or using CommandBox arguments)

You can also run the tests via command line:

`box testbox run verbose=false`

If you get any failures, you can run this with more verbose, but still compact output:

`box testbox run reporter=mintext`

# Copyright and License

Copyright (c) 2018 Abram Adams. All rights reserved.
The use and distribution terms for this software are covered by the Apache Software License 2.0 (http://www.apache.org/licenses/LICENSE-2.0) which can also be found in the file LICENSE at the root of this distribution and in individual licensed files.
By using this software in any fashion, you are agreeing to be bound by the terms of this license. You must not remove this notice, or any other, from this software.