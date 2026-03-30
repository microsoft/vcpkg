# 1. Download the code from your GitHub
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Aksh13673/Zenith
    REF v1.0.0
    SHA512 b7da7251786576b55be979f485122f8725968425ba36d640816b0b3db6168f8ccf4120ba20526e9930c8c7294e64d43900ad2aef9d5f28175210d0c3a417
    HEAD_REF main
)

# 2. Copy the header to the system include folder
file(INSTALL "${SOURCE_PATH}/zenith_c.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# 3. Install the license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
