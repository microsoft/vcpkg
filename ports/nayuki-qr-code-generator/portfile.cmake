vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nayuki/QR-Code-generator
    REF v1.7.0
    SHA512 34efa40c382b6e7d060a764936c4e2faa4fbbecd5ea4730492a2cb1960656ed67242d84e20a42400ffdee063ed6bcf3b860fef309d09ee71303f44abaafe9328
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}/cpp")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cpp"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
configure_file("${SOURCE_PATH}/Readme.markdown" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
