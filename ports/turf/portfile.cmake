vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO preshing/turf
    REF 9ae0d4b984fa95ed5f823274b39c87ee742f6650 # 2017-01-13
    SHA512 123078fa84ed3152491e31a5bd5988aa6407608844baf426d22bc391193f4834bd34ee88577350cf1a92dbf1c6397f82c95d0cbcc26de7492e8261e36454ade8
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DTURF_PREFER_CPP11=ON
        -DTURF_MAKE_INSTALLABLE=ON
)

vcpkg_install_cmake()

#vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/json-dto)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
