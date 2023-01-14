if (VCPKG_TARGET_IS_OSX)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jkuhlmann/gainput
    REF v1.0.0
    SHA512 56fdc4c0613d7260861885b270ebe9e624e940175f41e3ac82516e2eb0d6d229e405fbcc2e54608e7d6751c1d8658b5b5e186153193badc6487274cb284a8cd6
    HEAD_REF master
    PATCHES 
        install_as_cmake_package.patch
        fix-build.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" GAINPUT_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" GAINPUT_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGAINPUT_BUILD_SHARED=${GAINPUT_BUILD_SHARED}
        -DGAINPUT_BUILD_STATIC=${GAINPUT_BUILD_STATIC}
        -DGAINPUT_TESTS=OFF
        -DGAINPUT_SAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-gainput CONFIG_PATH share/unofficial-gainput)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
