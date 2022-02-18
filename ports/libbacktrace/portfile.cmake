if(VCPKG_TARGET_IS_WINDOWS)
    message("libbacktrace cannot be built using MSVC on Windows due to relying on the C++ unwind API https://itanium-cxx-abi.github.io/cxx-abi/abi-eh.html")
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
