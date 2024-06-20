vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nayuki/QR-Code-generator
    REF v1.8.0
    SHA512 0cdf0873e71aed124fc7357da86fb26f23fd26432f94c9752fa5a044085b26e5aece2115134d0e50213ff24be7c55818e7dec31205a68751065bc82ab0c2c6ac
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}/cpp")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cpp"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/unofficial-nayuki-qr-code-generator PACKAGE_NAME unofficial-nayuki-qr-code-generator)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
configure_file("${SOURCE_PATH}/Readme.markdown" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
