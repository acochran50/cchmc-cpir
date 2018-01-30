# MATLAB

This directory is for any reusable MATLAB scripts. Sets of files dedicated to specific projects should go in their own folders. Function files and standalone scripts should also go into properly named directories. See below for a list of suggestions

## Functions

The function `imslice.m` could go into a folder in this directory called `imslice`. It should be accompanied with a short `README.md` that describes a basic use-case for the function. **Function names are all lowercase.**

## Projects

Projects consisting of multiple files should go into their own directory. If someone wants to access the project or pull the software into a folder on their machine containing datafiles ready for analysis, they should be able to do so without fishing through several locations to find what they want. In other words, everything necessary to run your code, except possibly for datafiles, should be there. **Script names are all uppercase.**

For example, let's say you have an image processing project you're working on with 3 files:

  1. `imslice.m`, a function file
  2. `mansegment.m`, another function file, and
  3. `imageProcessing.m`, the script you're using to run the project

These files should go into a folder labeled `imageProcessing`, along with a **short** `README.md` describing what the project's aim is.

## Formatting

A few suggestions for formatting MATLAB code can be found [here](./MATLAB_FORMAT.md).

## Markdown

A guide with quick tips for writing Markdown (`*.md` files) can be found [here](https://guides.github.com/features/mastering-markdown/).
