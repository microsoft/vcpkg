vcpkg_fail_port_install(ON_TARGET "Linux" "OSX" "UWP" ON_ARCH "arm" "arm64")

vcpkg_download_distfile(ARCHIVE
    URLS "https://downloads.sourceforge.net/project/gsoap2/gsoap-2.8/gsoap_2.8.102.zip"
    FILENAME "gsoap_2.8.102.zip"
    SHA512 3cff65605b15f820c9d56e32575231fb6fb89927bafc1db85ac1f879acd8496d6f38b558e994d17cce475beae0976d5fafcff7f22b28cdfbec8b7ec4b08bcbe7
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
       "${CMAKE_CURRENT_LIST_DIR}/fix-build-in-windows.patch"
)

set(BUILD_ARCH "Win32")

# Handle binary files and includes
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/gsoap ${CURRENT_PACKAGES_DIR}/debug/tools)

if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    vcpkg_build_msbuild(
        USE_VCPKG_INTEGRATION
        PROJECT_PATH ${SOURCE_PATH}/gsoap/VisualStudio2005/soapcpp2/soapcpp2.sln
        PLATFORM ${BUILD_ARCH}
        TARGET Build
    )
    vcpkg_build_msbuild(
        USE_VCPKG_INTEGRATION
        PROJECT_PATH ${SOURCE_PATH}/gsoap/VisualStudio2005/wsdl2h/wsdl2h.sln
        PLATFORM ${BUILD_ARCH}
        TARGET Build
    )

    file(COPY ${SOURCE_PATH}/gsoap/VisualStudio2005/soapcpp2/release/soapcpp2.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/gsoap/)
    file(COPY ${SOURCE_PATH}/gsoap/VisualStudio2005/wsdl2h/release/wsdl2h.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/gsoap/)
    file(COPY ${SOURCE_PATH}/gsoap/VisualStudio2005/soapcpp2/debug/soapcpp2.exe DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/gsoap/)
    file(COPY ${SOURCE_PATH}/gsoap/VisualStudio2005/wsdl2h/debug/wsdl2h.exe DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/gsoap/)
else()
    message(FATAL_ERROR "Sorry but gsoap only can be build in Windows temporary")
endif()


file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/gsoap/stdsoap2.h ${SOURCE_PATH}/gsoap/stdsoap2.c ${SOURCE_PATH}/gsoap/stdsoap2.cpp ${SOURCE_PATH}/gsoap/dom.c ${SOURCE_PATH}/gsoap/dom.cpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle import files
file(COPY ${SOURCE_PATH}/gsoap/import DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# Handle plugin files
file(COPY ${SOURCE_PATH}/gsoap/plugin DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# Cleanup surplus empty directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/gsoap/plugin/.deps")    

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/INSTALL.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME install)
file(INSTALL ${SOURCE_PATH}/README.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME readme)

vcpkg_copy_pdbs()
