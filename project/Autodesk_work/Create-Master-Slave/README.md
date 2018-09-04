
# There are scripts to create a Jenkins-Slave-Master instance.

## 1. Create an instance with a 500G volume

#### a) Please change value of the following variables in this file  
> $InstanceName  
$vname

#### b) Then execute this script:  
&emsp;`step1-create_instance.ps1`  

When it finishes:  
a folder **"C:\JenkinsSlaveKit"** will been created.

## 2. Add an autologon administrator to this instance

#### a) Login this instance with yourself account.

#### b) Then execute this script:
&emsp;`step2-add_administrator.ps1`  

When it finishes:  
this instance will restart.

## 3. Bring volume online and format it, then install requirements.

#### a) Login this instance with 'ads\shqa_auto_vmware', 'Changeme4'

#### b) double click file to execute this script:
&emsp;`step3-01.bat`  

#### c) double click file to execute this script:
&emsp;`step3-02.bat`  

When it finishes:  
it will send the drive letter of the attached volume to a file "driveletter.txt".  
Requirements has been installed.  
Files has been copied.  
IP of this master instance in files has been revised.
