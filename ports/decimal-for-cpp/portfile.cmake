set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vpiotr/decimal_for_cpp
    REF 599372ee214ab37b5c0fc68148352321978f20ed
    SHA512 80c1e5068c1699ad819dfc4d47e316943b404ce8bc5fb0d8f8c48212ef79a2e41ca63e6846630993199b5ccda55c59cccc9206cf08d339070f9390782ca404d6
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/decimal.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/decimal-for-cpp")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/doc/license.txt"
)
