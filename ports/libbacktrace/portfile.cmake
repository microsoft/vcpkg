if (CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    vcpkg_fail_port_install(ALWAYS MESSAGE "The library relies on the C++ unwind API defined at https://itanium-cxx-abi.github.io/cxx-abi/abi-eh.html This API is only provided by GCC and clang. You are using MSVC.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ianlancetaylor/libbacktrace
    REF 4f57c999716847e45505b3df170150876b545088
    SHA512 1df2c9d3c119a2ec7b8b8940bff7ba6d28fe99587f565066ae25c216021431d3c26c8b336c38dd0490165244c66d68f9cba20dfc7836042b62f9d588946be4b5
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
