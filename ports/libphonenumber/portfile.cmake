vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/libphonenumber
    REF v8.13.1
    SHA512 e847c263ccc076070a669334536e8f4fe1b6864e8c0cec9992c430b2728512a96d9cdc3e8f0978b79a9fce64edaed85c369773b58706ca189115375ac5dca597
    HEAD_REF master
    PATCHES 
        "fix-re2-identifiers.patch"
        "fix-icui18n-lib-name.patch"
        "fix-absl-with-geocoder-off.patch"
        "remove-build-test.patch"   # Make build test a feature in future. For now, temp fix.
        "remove-shared-lib.patch"   # Needs -DBUILD_GEOCODER=OFF option
                                    # Work on building shared libs in future. For now, temp fix.
        fix-find-protobuf.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cpp"
    OPTIONS
        -DREGENERATE_METADATA=OFF
        -DUSE_RE2=ON
        -DBUILD_GEOCODER=OFF
        -DUSE_PROTOBUF_LITE=ON)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)