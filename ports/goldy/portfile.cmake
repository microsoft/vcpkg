vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO koubaa/goldy
    REF "v${VERSION}"
    SHA512 8ff9ac74d796cc5ac4660232cf55edda9f848aca4fd565e59d4e6a90c3d2c1ced444b96aa4f2ab4cfe300049eda5aaa275238ba4e7c341771ef3c8b723df79a0
    HEAD_REF main
)

# Download pre-built native library for target platform
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    vcpkg_download_distfile(GOLDY_FFI_ARCHIVE
        URLS "https://github.com/koubaa/goldy/releases/download/v${VERSION}/goldy_ffi-windows-x64.zip"
        FILENAME "goldy_ffi-${VERSION}-windows-x64.zip"
        SHA512 15142e06536046d4f2768c95256471efb8c0cb1b52a905f34aaab9636d5f98139b7a038afeace680879298695dfe952061a404eb7da5ef6999f65b8317455ef9
    )
elseif(VCPKG_TARGET_IS_LINUX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    vcpkg_download_distfile(GOLDY_FFI_ARCHIVE
        URLS "https://github.com/koubaa/goldy/releases/download/v${VERSION}/goldy_ffi-linux-x64.tar.gz"
        FILENAME "goldy_ffi-${VERSION}-linux-x64.tar.gz"
        SHA512 ebc70ffdc0895ed8755a5e475d0e06e91114998e0dab1a6a2db4f909a1b606a3b6c150e9325a23ff498a3d82c67ff7e433fe5524399bbbb4e4308f2969ac527f
    )
elseif(VCPKG_TARGET_IS_OSX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    vcpkg_download_distfile(GOLDY_FFI_ARCHIVE
        URLS "https://github.com/koubaa/goldy/releases/download/v${VERSION}/goldy_ffi-macos-x64.tar.gz"
        FILENAME "goldy_ffi-${VERSION}-macos-x64.tar.gz"
        SHA512 416ad1957f96fb7a9e6a5a0711ae58e75c0658f8f84014797b041b482698b4780fd422ffcd515e46796395a69400ece2487ff2225b7df729959c87b05da826e1
    )
elseif(VCPKG_TARGET_IS_OSX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    vcpkg_download_distfile(GOLDY_FFI_ARCHIVE
        URLS "https://github.com/koubaa/goldy/releases/download/v${VERSION}/goldy_ffi-macos-arm64.tar.gz"
        FILENAME "goldy_ffi-${VERSION}-macos-arm64.tar.gz"
        SHA512 7451fb6cbec47f869c295db480a2d9f32a064e0602e40cc8b9742543e78fccf35fae542e24d883b0ea632d803cc2789a120dfe880ca84e806b5f0091edf5007a
    )
else()
    message(FATAL_ERROR "Unsupported platform: ${VCPKG_TARGET_TRIPLET}")
endif()

vcpkg_extract_source_archive(
    BINARY_PATH
    ARCHIVE "${GOLDY_FFI_ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
)

# Install headers
file(INSTALL "${SOURCE_PATH}/cpp/include/goldy.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/cpp/include/goldy.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Install native library
if(VCPKG_TARGET_IS_WINDOWS)
    file(INSTALL "${BINARY_PATH}/lib/goldy_ffi.dll"
         DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(INSTALL "${BINARY_PATH}/lib/goldy_ffi.dll.lib"
         DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
         RENAME "goldy_ffi.lib")
    
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(INSTALL "${BINARY_PATH}/lib/goldy_ffi.dll"
         DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(INSTALL "${BINARY_PATH}/lib/goldy_ffi.dll.lib"
         DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib"
         RENAME "goldy_ffi.lib")
elseif(VCPKG_TARGET_IS_LINUX)
    file(INSTALL "${BINARY_PATH}/lib/libgoldy_ffi.so"
         DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(INSTALL "${BINARY_PATH}/lib/libgoldy_ffi.so"
         DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
elseif(VCPKG_TARGET_IS_OSX)
    file(INSTALL "${BINARY_PATH}/lib/libgoldy_ffi.dylib"
         DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(INSTALL "${BINARY_PATH}/lib/libgoldy_ffi.dylib"
         DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()

# Install CMake config and usage
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/goldy-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
