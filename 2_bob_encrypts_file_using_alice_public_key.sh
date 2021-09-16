#!/bin/bash

log()
{
      echo "$(date) $@"
}

export inputFile=inputFile.txt
export publicKey=alice.gpg
export outputFile=${inputFile}.gpg
export signatureFile=${inputFile}.gpg.sig

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
if [[ -f "${publicKey}" ]]; then
    log "[OK] public key file exists, ${publicKey}"
else 
    log "[ERROR] public key file does not exist, ${publicKey}.  Cannot continue"
#    exit 8
fi
if [[ -f "${inputFile}" ]]; then
    log "[OK] Input file exists, ${inputFile}"
else 
    log "[ERROR] Input file does not exist, ${inputFile}.  Cannot continue"
    exit 8
fi
log "[INFO] checking for requried files - Done"



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

# Not using key store, but supplied public key
log "[INFO] Encrypting ${inputFile} using ${publicKey} to ${outputFile}"
gpg --recipient-file  ${publicKey} --armor --output ${outputFile} --encrypt ${inputFile} 
retVal=$?
if [ ${retVal} -ne 0 ]; then
   log "[ERROR] Encrypting ${inputFile} using ${publicKey} to ${outputFile}"
   exit 8
fi


log "[INFO] Proceeding to Signing"
log "[INFO] Listing Keys "
gpg --list-keys

# list the keys
# awk find the lines starting with 6 spaces
# grep get non-blank lines
# head take the first
keyVal=$(gpg --list-keys | awk -F"      " '{print$2}' | grep -m 1 . | head -1)
log "[INFO] Using the following key for signing : ${keyVal}"

# Sign the file using our private key
# Note, using local key store that contains a specific private key
log "[INFO] Signing ${outputFile} to ${signatureFile}"
gpg --output ${signatureFile} --default-key ${keyVal} --armor --detach-sig ${outputFile} 
retVal=$?
if [ ${retVal} -ne 0 ]; then
   log "[ERROR] Signing ${outputFile} to ${signatureFile}"
   exit 8
fi
log "[INFO] Signing ${outputFile} to ${signatureFile} - Done"


################################################################################
# WSL useful commands
# "/mnt/c/Program Files/IDM Computer Solutions/UltraEdit/uedit64.exe" 2_bob_encrypts_file_using_alice_public_key.sh
# sudo chown jarrod *.sh; chmod 755 *.sh; ./2_bob_encrypts_file_using_alice_public_key.sh