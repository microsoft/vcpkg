vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  inie0722/CTL
    REF 58ca0f229aff093ada66955993cada93e01da18c #1.0.0
    SHA512 6e1fcd70be0750b3e45de80d6fb30471fdbd8bbd23afd7ff9fb8c3b9fe61669cd02773cf2b6573348dd2905a303845627d3f5f3e647f4e1261db4cc570cf5099
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
