#!/bin/bash
# Username and password for the Nielsen MFT portal
USERNAME=""
PASSWORD=""
# Optional: Storage account SAS URL for the target container
SAS_URL=""
# Optional: Storage account connection string; leave SAS_URL empty when using this option
CONNECTION_STRING=""
# Target container name when using the Connction_string parameter
CONTAINER_NAME=""
# Overwrite: if false script checks if file exists on target and will skip extraction if present
OVERWRITE="false"