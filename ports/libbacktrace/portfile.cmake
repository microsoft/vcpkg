if(VCPKG_TARGET_IS_WINDOWS)
    message("libbacktrace cannot be built using MSVC on Windows due to relying on the C++ unwind API https://itanium-cxx-abi.github.io/cxx-abi/abi-eh.html")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ianlancetaylor/libbacktrace
    REF 14818b7783eeb9a56c3f0fca78cefd3143f8c5f6
    SHA512 d96c337cda6d230b162d983b2ab6ff6643895158f1d6f2e814bf28a2212a0cf46313935c2ed95a4408e6ad1da3c0c1ccb09847cf8b8b2ca6ad299101b8f79dd4
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
