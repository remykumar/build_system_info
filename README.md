# build_system_info
Build script for getting system stats

**Code 1: Build script**

Source code link: https://github.com/remykumar/build_system_info

Build script is the shell script which does the installation, execution of the Reference Software (python code) and makes sure supporting softwares, directories are present. This also starts the http server (if stopped), does a status health check for the deployed html file and gets the URL to be accessed for the system info/monitoring page.

Btw, Reference Software here is a python code (script) which will pull some key system information & monitoring data (CPU usage, Memory usage & disk usage) from the Host Operating System and creates a html page. This html file can be deployed on a web server (http server) to be viewed on a browser. The python code runs continuously every 60 seconds and updates the html – so the system info (or monitoring) page is dynamically updated. ( https://github.com/remykumar/system_info_devops )


**Execution instruction for Build script:**

1. Clone the source
 
    `git clone https://github.com/remykumar/build_system_info.git`

2. Move the build.sh to your home directory (assuming you did the clone from your home directory) 
  
    `cp ~/build_system_info/build.sh ~ (or) cp ~/build_system_info/build.sh .`

3. Before executing, make sure http port 80 is open & please check the following commands

    `pwd` : You should in your home directory

    `sudo su -` : You should be able do a password-less sudo to root & execute all sudo commands without password. This can be done by editing the visudo file and adding an entry like remy ALL=(ALL) NOPASSWD: ALL
   
   Reference: https://www.cyberciti.biz/faq/linux-unix-running-sudo-command-without-a-password/

4. Please note: This script will download, install and execute another code from 

   https://github.com/remykumar/system_info_devops

5. To execute this script (do it from your home directory & by using your user account, not root):

    `./build.sh`

6. Successful execution of the script will result in these kinds of messages on console :
  ```
  Building the code .....Build Complete!
  -------------------------------------------------------------------------
  Deploying the code on the http server .....Deploy Complete!
  -------------------------------------------------------------------------
  Please access the System Stats (System Information) page here : 
  http://192.168.42.129/systeminfo.html
  ```
This build starts a python code which runs indefinitely (every 60 seconds) to collect system stats from the machine it is been run on. 

7. To kill the python script & stop the stats collection:
 
    `pkill -f sysinfo.py (Note : To check if the process is running, pgrep -f sysinfo.py)`

Note: This script has no to low overhead. Didn’t notice any CPU increase on a low config virtual machine.



<br>

**Some tasks done by the Build Script (build.sh):**
-	Installs git, python3 and the http server 
-	Starts the http server & enable it on reboot
-	Remove the old code directory and use git to download fresh code every time  
-	Gets the Python code (Reference Software) from git
-	Gets the internal and external IPs of the host machine
-	Moves the html and image to the exact location on http server root directory
-	Health check: curls the External and Internal IP addresses to check the http 200 success status. Tries to use External IP first since this code is to be run on AWS EC2 instance as well.


