# Contributing

## Project Flow

This repository isn't designed to create a production-level application. Most of the scripts and manifests found here will be dedicated to different analyses or projects altogether. As such, we should try to maintain clear lines of separation in the directory structure so that we don't run into any issues, but can still collaborate productively.

Git is love, git is life (if you're designing software). Git and GitHub offer tons of powerful tools and tricks for creating and maintaining robust projects. Because this repository is purposed slightly differently, we should take project flow recommendations with a grain of salt. **Briefly**, I'm going to lay out the important things to know about how you should contribute to this repository. A more software developer-oriented guide for using GitHub effectively can be found **[here](https://guides.github.com/introduction/flow/)**.

* **GitHub Desktop vs. Git CLI**
  * If you're used to using Git or the command line in general, by all means feel free to use your favorite terminal to push & pull to/from this repository.
  * If you'd prefer to take a more GUI-oriented approach, GitHub offers a **[desktop application](https://desktop.github.com/)** for both Windows and macOS users (not Linux, unfortunately). This allows you to easily add files/folders to the repository, commit your changes to your preferred branch, and push them to GitHub without ever having to touch a terminal.

* **Adding something new**
  * If you're adding a new project or set of files to the repository, do so by creating a new folder with a **descriptive name**. Everyone should know what the folder is for.
  * The general process for adding a file or making a change is the same: **add, commit, push.** You will add your changes (create a new file or edit an existing one), **commit** the changes to stage them for addition to this remote repository with a log message, and **push** your changes here. **Changes should be well documented, with commit messages explicitly stating what was altered.**
  * The beauty of version control is that a full history of the files and their states at the point of any given commit will exist as long as this repository does. Need to revert to the form your reconstruction script was in as of a commit you made 8 months ago? Easy.

* **


Let's _try_ to keep things clean and orderly. To make sure everyone is following the same rules, all contributions/etc. should follow the **[GitHub Flow](https://guides.github.com/introduction/flow/)**. This means that each time noteworthy changes are made, the process should include:

* **Creating a branch**
  * Features and new ideas should be in a separate branch that others can see, but that won't have any effects on the current working version of the project.
* **Adding commits**
  * Make some changes to the project in the new branch to flesh things out and work towards your new feature. Well-labeled commits make it easy for everyone else to see what you're working on, how you're working on it, and what your end goal might be.
  * Use **short, meaningful** commit messages.
* **Opening a pull request**
  * Light a signal fire so everyone knows you want to discuss what you're working on.
* **Reviewing changes with everyone**
  * Pull requests are for discussions. Make sure everyone's opinions have been heard before moving too far ahead with something that constitutes a major project decision.
* **Deploying and testing**
  * Use GitHub to deploy your new feature and run tests before throwing the change into the working project source. Let everyone review the pieces and parts of your code if they'd like to. This is a final quality control check before making a direct alteration to the code that users will run.
* **Merging**
  * Changes verified? Add them to the production-level code.
  * Pull requests will maintain a history of the changes made to everything.
  
## Default Branch

The default branch for this project is set to **_develop_**. This means that all branches for new features will be created from and merged into this branch, **not the _master_ branch**. The **_master_** branch is reserved for the working, production-level source (once it exists).

## Comments, Documentation and Formatting

If someone else is going to use your code in the future, **please format well and write decent comments.** Few things are worse than inheriting someone's project and having to parse through each line just to understand what the general purpose of their software is. Write **brief and descriptive** comments as often as you think would be necessary for someone else to be able to grasp your thought process **without having to ask you any questions**. Good formatting is another key to writing understandable code. Especially with MATLAB, matrix indices can often be hard to read. Be liberal with newlines and indentations if it helps improve the readability of your software.

