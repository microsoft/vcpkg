# According to Bloomberg Helpdesk on 2023-07-18, the last digit of the version string is just a build identifier,
# not an actual version identifier, and can be different between the latest Linux and Windows distfiles.

if (VCPKG_TARGET_IS_LINUX)
    vcpkg_download_distfile(ARCHIVE
        URLS "https://bcms.bloomberg.com/BLPAPI-Generic/blpapi_cpp_3.20.2.1-linux.tar.gz"
        FILENAME "blpapi_cpp_3.20.2.1-linux.tar.gz"
        SHA512 4d4cf999d6cc2bf924dfb79fdabd2a30c2d1251e4e56fe856684c4f8e0be03dcd33f69d75f8706d381bb35ad4b1ad954a5cc88156a80e053f2601d8257815863
    )
elseif (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_download_distfile(ARCHIVE
        URLS "https://bcms.bloomberg.com/BLPAPI-Generic/blpapi_cpp_3.20.2.2-windows.zip"
        FILENAME "blpapi_cpp_3.20.2.2-windows.zip"
        SHA512 f6e66d75a8f16c014737ae813c65304e38423e5ab955eb98fb7f487eecda06bcc9d84733b55957ac577f689da2af753fdeb132feb0eb02a9ec38e8f3868ad795
    )
endif()

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES update-blpapi-lib-include-dir.patch
)

if ("${VCPKG_TARGET_ARCHITECTURE}" MATCHES "x86")
    set(BITS_SUFFIX 32)
elseif ("${VCPKG_TARGET_ARCHITECTURE}" MATCHES "x64")
    set(BITS_SUFFIX 64)
else()
    message(FATAL_ERROR "Unrecognized architecture.")
endif()

if (VCPKG_TARGET_IS_LINUX)
    file(GLOB SO_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/Linux/*${BITS_SUFFIX}.so")
else()
    file(GLOB DLL_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/lib/*${BITS_SUFFIX}.dll")
    file(GLOB LIB_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/lib/*${BITS_SUFFIX}.lib")
endif()

if (VCPKG_TARGET_IS_LINUX)
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

file(INSTALL "${SOURCE_PATH}/License.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
