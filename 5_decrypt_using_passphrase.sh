#!/bin/bash
clear

log()
{
      echo "$(date) $@"
}

##############################################################################
# NOTE, it is assumed that you have already run the example that encrypts 
#       using passphrase
##############################################################################
export outputFile=inputFile.txt
export inputFile=${outputFile}.gpg

##############################################################################
# NOTE, passphrase is a parameter to the script
# NOTE, passphrase is a parameter to the script
##############################################################################
export pass=${1}
echo ${1}
if [ ! -n "${1}" ]; then
   log "[ERROR] passphrase not passed on the command line"
   exit 8
fi
if [ -z ${pass}+x} ]; then 
   log "[ERROR] passphrase not passed on the command line"
   exit 8 
fi

##############################################################################
# Clean up existing files if they exist
##############################################################################
log "[INFO] Looking for existing output file to delete"
if [ -f ${outputFile} ]; then
    log "[INFO] deleting existing file ${outputFile}"
    rm ${outputFile}
    retVal=$?
    if [ ${retVal} -ne 0 ]; then
       log "[ERROR] deleting existing file ${outputFile}"
       exit 8
    fi
fi

##############################################################################
# Check for required files
##############################################################################
log "[INFO] checking for requried files"
if [[ -f "${inputFile}" ]]; then
    log "[OK] input file exists, ${inputFile}"
else 
    log "[ERROR] input file does not exist, ${inputFile}.  Cannot continue"
    exit 8
fi
log "[INFO] checking for requried files - Done"



##############################################################################
# The Business end
# Providing the private key is in your key ring, gpg will work out which one to use
##############################################################################
log "[INFO] Decrypting ${inputFile} to ${outputFile}"
gpg --batch --passphrase ${pass} --output ${outputFile} --decrypt ${inputFile}
retVal=$?
if [ ${retVal} -ne 0 ]; then
   log "[ERROR] Decrypting ${inputFile} to ${outputFile}"
   exit 8
fi

head ${outputFile}

##############################################################################
# "/mnt/c/Program Files/IDM Computer Solutions/UltraEdit/uedit64.exe" 5_decrypt_using_passphrase.sh
# sudo chown jarrod *.sh; chmod 755 *.sh; ./5_decrypt_using_passphrase.sh