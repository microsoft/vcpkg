vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brazier-tech/brazier
    REF 8935d4aefa04ff7ccfecf62f593733c93d27ed9d
    SHA512 70ce13fbdf664f02b75a67edb80fb0e3869e535bd88558477bc00bb5bcc24025bb347747c040e9cbedb0b9ce6a2e12f69167e2003965598f55494a483d932fe1
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/brazier" 
    OPTIONS -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME brazier-core CONFIG_PATH share/brazier-core)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/COPYING")