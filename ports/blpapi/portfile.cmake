# According to Bloomberg Helpdesk on 2023-07-18, the last digit of the version string is just a build identifier,
# not an actual version identifier, and can be different between the latest Linux and Windows distfiles.

if(VCPKG_TARGET_IS_LINUX)
    vcpkg_download_distfile(ARCHIVE
        URLS "https://blpapi.bloomberg.com/download/releases/raw/files/blpapi_cpp_${VERSION}.1-linux.tar.gz"
        FILENAME "blpapi_cpp_${VERSION}.1-linux.tar.gz"
        SHA512 33f19761c71a42528e090c5fc8831898b6616a530bc3dad071ffbca23f3b6a038022da41a0339275c3001b21688e9d9dc010aae3050ddd2df8823c92a16546c6
    )
elseif(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_download_distfile(ARCHIVE
        URLS "https://blpapi.bloomberg.com/download/releases/raw/files/blpapi_cpp_${VERSION}.1-windows.zip"
        FILENAME "blpapi_cpp_${VERSION}.1-windows.zip"
        SHA512 c65dd9aff3fe4f5b656d84cb8f5ad9c9d280c0aaffb15d28efef60a4b462d1cd62a9f80ec8f1029a47ba980c2b7a81a22a861379ce202ee8f9dae8f3688ad211
    )
elseif(VCPKG_TARGET_IS_OSX)
    vcpkg_download_distfile(ARCHIVE
        URLS "https://blpapi.bloomberg.com/download/releases/raw/files/blpapi_cpp_${VERSION}.1-macos-arm64.tar.gz"
        FILENAME "blpapi_cpp_${VERSION}.1-macos-arm64.zip"
        SHA512 d1db099e1e2b0942c55f2a0583f5612695262434f62908b0c980ec66142880f75d69083f2932dc8b38afb4f9d08ad296216ea040fe33b11fe44a8cf300fb2c48
    )
endif()

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES update-blpapi-lib-include-dir.patch
)

if("${VCPKG_TARGET_ARCHITECTURE}" MATCHES "x86")
    set(BITS_SUFFIX 32)
elseif("${VCPKG_TARGET_ARCHITECTURE}" MATCHES "x64")
    set(BITS_SUFFIX 64)
elseif(NOT VCPKG_TARGET_IS_OSX)
    message(FATAL_ERROR "Unrecognized architecture.")
endif()

if(VCPKG_TARGET_IS_LINUX)
    file(GLOB SO_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/Linux/*${BITS_SUFFIX}.so")
elseif(VCPKG_TARGET_IS_OSX)
    file(GLOB SO_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/Darwin/*.so")
else()
    file(GLOB DLL_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/lib/*${BITS_SUFFIX}.dll")
    file(GLOB LIB_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/lib/*${BITS_SUFFIX}.lib")
endif()

if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
    file(COPY ${SO_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    if (NOT VCPKG_BUILD_TYPE)
        file(COPY ${SO_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    endif()
else()
    file(COPY ${DLL_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(COPY ${LIB_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    if (NOT VCPKG_BUILD_TYPE)
        file(COPY ${DLL_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(COPY ${LIB_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    endif()
endif()

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

file(GLOB CMAKE_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/cmake/*.cmake")
file(COPY ${CMAKE_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.txt")
