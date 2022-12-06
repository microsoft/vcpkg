vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/libphonenumber
    REF v8.13.1
    SHA512 e847c263ccc076070a669334536e8f4fe1b6864e8c0cec9992c430b2728512a96d9cdc3e8f0978b79a9fce64edaed85c369773b58706ca189115375ac5dca597
    HEAD_REF master
    PATCHES 
        "fix-re2-identifiers.patch"
        "fix-windows-static-link-icu-lib.patch"
        "fix-absl-with-geocoder-off.patch"
        # "fix-ninja-error-multiple-rules.patch" Commenting this out for remove-shared-lib patch instead
        "remove-shared-lib.patch" # Getting ninja error with multiple rules generating
                                  # same lib name (hence the fix-ninja patch above) but that created
                                  # an error during release, which I am fixing by setting option
                                  # set(BUILD_SHARED_LIB false) and have -DREGENERATE_METADATA=OFF.
                                  # Unsure if shared libs are necessary to keep. For now, temp fix.
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cpp"
    OPTIONS
        # Metadata is included in source so regeneration is unnecessary. Disabling removes need for java.exe in build system.
        # See https://github.com/google/libphonenumber/pull/2363
        -DREGENERATE_METADATA=OFF
        -DUSE_RE2=ON
        # Geocoder does not build successfully on Windows.
        # See https://github.com/microsoft/vcpkg/pull/10088/files
        -DBUILD_GEOCODER=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)