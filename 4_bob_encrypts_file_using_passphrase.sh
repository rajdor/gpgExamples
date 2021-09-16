#!/bin/bash

log()
{
      echo "$(date) $@"
}

export inputFile=inputFile.txt
export outputFile=${inputFile}.gpg
export signatureFile=${inputFile}.gpg.sig

##############################################################################
# NOTE, THIS SCRIPT REQUIRES apg 
# NOTE, THIS SCRIPT REQUIRES apg 
# NOTE, THIS SCRIPT REQUIRES apg 
##############################################################################

log "[INFO] Start - encrypt script example"

##############################################################################
# Clean up existing files if they exist
##############################################################################
log "[INFO] Looking for existing file to delete (this will be recreated)"
if [ -f ${inputFile} ]; then
    log "[INFO] deleting existing file ${inputFile}"
    rm ${inputFile}
    retVal=$?
    if [ ${retVal} -ne 0 ]; then
       log "[ERROR] deleting existing file ${inputFile}"
       exit 8
    fi
fi
if [ -f ${outputFile} ]; then
    log "[INFO] deleting existing file ${outputFile}"
    rm ${outputFile}
    retVal=$?
    if [ ${retVal} -ne 0 ]; then
       log "[ERROR] deleting existing file ${outputFile}"
       exit 8
    fi
fi
if [ -f ${signatureFile} ]; then
    log "[INFO] deleting existing file ${signatureFile}"
    rm ${signatureFile}
    retVal=$?
    if [ ${retVal} -ne 0 ]; then
       log "[ERROR] deleting existing file ${signatureFile}"
       exit 8
    fi
fi
log "[INFO] Looking for existing temp files to delete - Done"


##############################################################################
# Generate a Input file with random text
##############################################################################
log "[INFO] generating random text to ${inputFile}"
base64 /dev/urandom | awk '{print(0==NR%10)?"":$1}' | sed 's/[^[:alpha:]]/ /g' | head -50 > ${inputFile}
retVal=$?
if [ ${retVal} -ne 0 ]; then
   log "[ERROR] generating random text to ${inputFile}"
   exit 8
fi
log "[INFO] generating random text to ${inputFile} - Done"


##############################################################################
# Check for required files
##############################################################################
log "[INFO] checking for requried files"
if [[ -f "${inputFile}" ]]; then
    log "[OK] Input file exists, ${inputFile}"
else 
    log "[ERROR] Input file does not exist, ${inputFile}.  Cannot continue"
    exit 8
fi
log "[INFO] checking for requried files - Done"


##############################################################################
# Generate passphrase
##############################################################################
pwdline="$(apg -m 32 -l | head -n 1)"
arr=(${pwdline//;/ })
export pass=${arr[0]}
export pronouncable=${arr[1]}

log "[INFO] Key          :  ${pass}"
log "[INFO] Pronouncable : ${pronouncable}"


##############################################################################
# Check gpg version
##############################################################################
log "[INFO] checking for requried gpg"

VAR="$(gpg --version | grep -o 'gpg (GnuPG) 2.2.19' | wc -l)"
retVal=$?
if [ ${retVal} -ne 0 ]; then
   log "[ERROR] getting gpg version"
   exit 8
fi
if [ ${VAR} -ne 1 ]; then
   log "[ERROR] Unable to match expected gpg version"
   exit 8
fi 
VAR="$(gpg --version | grep -o 'libgcrypt 1.8.5' | wc -l)"
retVal=$?
if [ ${retVal} -ne 0 ]; then
   log "[ERROR] getting gpg libcrypt version"
   exit 8
fi
if [ ${VAR} -ne 1 ]; then
   log "[ERROR] Unable to match expected gpg libcrypt version"
   exit 8
fi 



##############################################################################
# The Business end
##############################################################################
log "[INFO] Encrypting ${inputFile} using ${pass} to ${outputFile}"

gpg --passphrase  ${pass} --symmetric --batch --armor --output ${outputFile}  ${inputFile}

retVal=$?
if [ ${retVal} -ne 0 ]; then
   log "[ERROR] Encrypting ${inputFile} using ${publicKey} to ${outputFile}"
   exit 8
fi


# gpg --batch --passphrase ${pass} --decrypt inputFile.txt.gpg

################################################################################
# WSL useful commands
# "/mnt/c/Program Files/IDM Computer Solutions/UltraEdit/uedit64.exe" 4_bob_encrypts_file_using_passphrase.sh
# sudo chown jarrod *.sh; chmod 755 *.sh; ./4_bob_encrypts_file_using_passphrase.sh