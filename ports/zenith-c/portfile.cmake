# 1. Download the code from your GitHub
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Aksh13673/Zenith
    REF v1.0.0
    SHA512 0 # <--- This will cause a failure. See below how to fix it.
    HEAD_REF main
)

# 2. Copy the header to the system include folder
file(INSTALL "${SOURCE_PATH}/zenith_c.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# 3. Install the license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
