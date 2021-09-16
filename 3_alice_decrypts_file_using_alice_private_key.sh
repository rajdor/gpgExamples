#!/bin/bash
clear

log()
{
      echo "$(date) $@"
}

##############################################################################
# NOTE, it is assumed that you have already visited and read the contents of
#       1_alice_generate_keys.sh
##############################################################################

export outputFile=inputFile.txt
export inputFile=${outputFile}.gpg
export signatureFile=${outputFile}.gpg.sig

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
if [[ -f "${signatureFile}" ]]; then
    log "[OK] signature file file exists, ${signatureFile}"
else 
    log "[ERROR] signature file does not exist, ${signatureFile}.  Cannot continue"
#    exit 8
fi
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
gpg --verify ${signatureFile} ${inputFile}
retVal=$?
if [ ${retVal} -ne 0 ]; then
   log "[ERROR] Verifying ${inputFile} using ${signatureFile}"
   exit 8
fi
gpg --decrypt --output ${outputFile} ${inputFile}
retVal=$?
if [ ${retVal} -ne 0 ]; then
   log "[ERROR] Decrypting ${inputFile} to ${outputFile}"
   exit 8
fi

head ${outputFile}


##############################################################################
# "/mnt/c/Program Files/IDM Computer Solutions/UltraEdit/uedit64.exe" 3_alice_decrypts_file_using_alice_private_key.sh
# sudo chown jarrod *.sh; chmod 755 *.sh; ./3_alice_decrypts_file_using_alice_private_key.sh