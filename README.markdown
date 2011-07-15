USING
=====

Each branch contains the a different lab.

master contains the base for most labs.  The other branches are
solutions.  Note that AdvancedEncryption lab starts with the
BasicEncryptionSolution branch as a base.

To use the app, switch to the branch you want, run XCode in the
directory and build/run on the iPhone simulator.

You will need to be running the server for this to work, information
on how to run it is available in it's README.


LAB DESCRIPTIONS
================
 
* Secure Connection
 * Student observes sensitive traffic over a non-HTTPS connection
 * Run wireshark to demonstrate this
 * The solution involves running over https, can change this in the setting of the app, and there is a flag in the server to do this 
 * Video exists (I think yuk fai has it)
* Parameter manipulation
 * Server does not validate input, student sends malicious input (negative money transfer)
 * Video exists
* Basic Encryption
 * Sensitive data is stored unencrypted
 * video exists
* Advanced Encryption
 * Sensitive data is stored encrypted using a pre-set key
 * key is found by running strings on the binary or decompiling
* Insecure Logging
 * App logs sensitive data
 * run adb logcat to see
* Password Complexity
 * App allows simple passwords
