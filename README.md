mocha-term-cov-reporter
=======================

Mocha reporter for displaying a code coverage report in the terminal.

If you don't really feel like firing up a browser just to get a quick indication of what your code coverage is like, then this is for you

Quick, simple, works everywhere.



Installation
------------

    npm install mocha-term-cov-reporter



Usage
-----

    mocha --reporter mocha-term-cov-reporter



Example output
--------------

![Example](https://raw.githubusercontent.com/jakobmattsson/mocha-term-cov-reporter/master/docs/example_output.png)



Explanation of output
---------------------

What you can see is that two files have been tested; index.coffee and tools.coffee. The number of lines contained in the file and the percentage of those line that was covered is printed at the top and at the bottom of the report.

The main body of the report is all the lines NOT covered by tests (marked in read), and five lines of context before and after each uncovered line. The line numbers are printed along with the code itself.
