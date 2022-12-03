vcpkg_from_github(
    ARCHIVE
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/libphonenumber
    REF v8.13.1
    SHA512 e847c263ccc076070a669334536e8f4fe1b6864e8c0cec9992c430b2728512a96d9cdc3e8f0978b79a9fce64edaed85c369773b58706ca189115375ac5dca597
    HEAD_REF master
    PATCHES 
        "change-icui18n-lib-name.patch"
        # "fix-ninja-error-multiple-rules.patch" Commenting this out for remove-shared-lib patch instead
        "remove-shared-lib.patch" # Getting ninja error with multiple rules
                                  # generating same lib name (hence the fix-ninja patch) but that created
                                  # an error during release, which I am fixing by commenting out the
                                  # option to build shared libs versions of phonenumber & geocoding.
                                  # Unsure if shared libs are necessary to keep. For now, temp fix.
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cpp"
    OPTIONS
        -DREGENERATE_METADATA=OFF
        -DUSE_RE2=OFF
)

vcpkg_cmake_install()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
