vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenMPT/openmpt
    REF "libopenmpt-${VERSION}"
    SHA512 3c657f807029adcf4a4fbba77502ca13e41422128336099a408ac3710f348c79243db71486f55c2a7a85ee4e03b7803d61b7aeb315a57184ed5e243614782d78
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DVERSION=${VERSION}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/libopenmpt/libopenmpt_config.h "defined(LIBOPENMPT_USE_DLL)" "0")
else()
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/libopenmpt/libopenmpt_config.h "defined(LIBOPENMPT_USE_DLL)" "1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
