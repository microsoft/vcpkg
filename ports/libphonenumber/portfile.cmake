# Note libphonenumber supports dynamic library but this port needs additional work to install it properly.
# Currently would fail during post-build validation:
#   Import libs were not present in ...
#   The following DLLs have no exports: .../bin/libphonenumber.dll
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/libphonenumber
    REF v8.11.4
    SHA512 6ef958db4b9470a3bfc8cc7169213ef0a7e90247f3e1911e179602810b2a8f8c227422c4f624aa5eb32497712fae878f1cfc053b9189cdc2d4102aa73c6dcfd1
    HEAD_REF master
    PATCHES
        001-cmakelists-use-find-package.patch
        002-cmakelists-fix-build-static-lib.patch
        003-cmakelists-regenerate-metadata.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/cpp
    PREFER_NINJA
    OPTIONS
        -DBUILD_STATIC_LIB=ON 
        # Geocoder does not build successfully on Windows
        -DBUILD_GEOCODER=OFF
        # Metadata is included in source so regeneration is unnecessary. Disabling removes need for java.exe in build system.
        # See https://github.com/google/libphonenumber/pull/2363
        -DREGENERATE_METADATA=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/cpp/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
