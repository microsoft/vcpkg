vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kauth
    REF "v${VERSION}"
    SHA512 438d599b2410c799bd4383013dd216221efb4579b19242453fa38497d738910550eda6707f74446193c89c1958abb2d88dce07f625550040b62444dea16d6cd6
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5Auth)

if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/kauth/kauth-policy-gen${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    vcpkg_copy_tools(
        TOOL_NAMES kauth/kauth-policy-gen
        DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/kauth"
        AUTO_CLEAN
    )
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/kauth")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin/kauth")
    vcpkg_clean_executables_in_bin(FILE_NAMES none)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
