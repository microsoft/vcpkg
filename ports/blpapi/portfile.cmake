# According to Bloomberg Helpdesk on 2023-07-18, the last digit of the version string is just a build identifier,
# not an actual version identifier, and can be different between the latest Linux and Windows distfiles.

if (VCPKG_TARGET_IS_LINUX)
    vcpkg_download_distfile(ARCHIVE
        URLS "https://blpapi.bloomberg.com/download/releases/raw/files/blpapi_cpp_${VERSION}.1-linux.tar.gz"
        FILENAME "blpapi_cpp_${VERSION}.1-linux.tar.gz"
        SHA512 3D1FC0E8E37E21EE53310649EA7D915A4E991DD2FCA400FCD5E490C4533F6C83710426C5D98927631BBDB2622D9FFA864096C82F275DC1C547FCAFE9D1013895
    )
elseif (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_download_distfile(ARCHIVE
        URLS "https://blpapi.bloomberg.com/download/releases/raw/files/blpapi_cpp_${VERSION}.1-windows.zip"
        FILENAME "blpapi_cpp_${VERSION}.1-windows.zip"
        SHA512 ED57BF390417D6ED189A3D4379DAE5716441627B20C63B8BEBAAC0AD66C32B89D17697B1C5CE79010F7FFF3F71BC6EC57D15A5D79B597F3507A0A4D2658A6103
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.txt")
