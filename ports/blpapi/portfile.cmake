# According to Bloomberg Helpdesk on 2023-07-18, the last digit of the version string is just a build identifier,
# not an actual version identifier, and can be different between the latest Linux and Windows distfiles.

if(VCPKG_TARGET_IS_LINUX)
    vcpkg_download_distfile(ARCHIVE
        URLS "https://blpapi.bloomberg.com/download/releases/raw/files/blpapi_cpp_${VERSION}.1-linux.tar.gz"
        FILENAME "blpapi_cpp_${VERSION}.1-linux.tar.gz"
        SHA512 c08fd319ad531a6c1bb39286349a8ad5ffb3e557559d370888baa5d73e347fb9ed64f0fa73cd77f26f2e87e69709b1abb840c3a61723da59c6b0640d9d0031f6
    )
elseif(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_download_distfile(ARCHIVE
        URLS "https://blpapi.bloomberg.com/download/releases/raw/files/blpapi_cpp_${VERSION}.1-windows.zip"
        FILENAME "blpapi_cpp_${VERSION}.1-windows.zip"
        SHA512 1d9bc4f9fab0a279cd8bb70c451ed5788caf87c52e82b071f3a74f9469d25e342a82e9d92ba87275129df8c1a85d982590f93020cb76c7d05d7408c2b77f78e2
    )
elseif(VCPKG_TARGET_IS_OSX)
    vcpkg_download_distfile(ARCHIVE
        URLS "https://blpapi.bloomberg.com/download/releases/raw/files/blpapi_cpp_${VERSION}.1-macos-arm64.tar.gz"
        FILENAME "blpapi_cpp_${VERSION}.1-macos-arm64.zip"
        SHA512 58f70a166bef66b642548b4bb332170e56fcbedd89c7a2e2c85ff91b6b20565f4573e8d16cd94cf048d47b9b795ac29052cbbcb3c29335e6cc6bb45865ad90d0
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
