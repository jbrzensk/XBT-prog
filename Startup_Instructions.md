# Startup instructions for the **NEW** XBT programs

The ferret environment needs to be setup once, and then invoked each time you login.
This can be simplified with some .bashrc edits later.

## Building the Executables
Navigate to the location you would like the programs folder installed. Run the command
```bash
git clone https://github.com/jbrzensk/XBT-prog.git
```
This will create a folder at your location `XBT-prog`.

Navigate into the folder, `cd XBT-prog`, and make all of the executables.
```bash
make all
```

You should get a bunch of purple **warnings**, but no errors. The warnings tell us the code is old, but should still function!

Next we are going to add this location to our PATH, so we can call program from here without specifying the directory. Run 

```bash
source add_to_path.sh
```

YEAH! Done! Now lets setup Ferret.

## Ferret Setup
Ferret has evolved, and is now PyFerret. BUT, the same old commands work with it.

Many Python programs are run in their own **environment**, because they have their own dependencies, and specific features they need, which may conflict with other Python programs. For this, we have our own Ferret environment we will load.

Run the command
```bash
conda activate /home/jabrzenski/.conda/envs/ferret
```

You should now have `(ferret)` in front of your prompt! Thats it!

Run `ferret`, and then, at the ferret prompt, `go tutorial` to verify that ferret is indeed working.

## Add to .bashrc and never do this again!
To make these permanent, lets add a couple commands to our bashrc.

### pwd the directory of all the executables
Run `pwd`, and make note of the directory you have installed the executables

```bash
(ferret) me@savu:~/XBT-prog$ pwd
/home/user/XBT-test
```

Next, we edit the `~/.bashrc` file using either `vim` or `nano`.
```bash
vim ~/.bashrc
```
The file will have many lines of features, all of which are loaded when you login.

At the bottom, add the following two lines of code:

`export PATH=$PATH:/path/to/your/xbt-test/from/pwd`

`conda activate /home/jabrzenski/.conda/envs/ferret`

Save your work, and logoff the system.
Log back in, and you should see `(ferret)` in front of the prompt, and all of the executables should be accessible. (Try running `maketic.x`).

You should be good to go. You should not ever have to run any of these commands again.
If you edit any of the executables, you can remake the executables by navigating to that directory and running `make all`, or `make maketic.x` or whatever file you edited.


