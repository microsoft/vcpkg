include(vcpkg_common_functions)
set(GSOAP_VERSION 2.8)
set(GSOAP_SUB_VERSION .82)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/gsoap-${GSOAP_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://ayera.dl.sourceforge.net/project/gsoap2/gsoap-${GSOAP_VERSION}/gsoap_${GSOAP_VERSION}${GSOAP_SUB_VERSION}.zip"
    FILENAME "gsoap_${GSOAP_VERSION}${GSOAP_SUB_VERSION}.zip"
    SHA512 daf6a1870fe43beb20d0faf646b171c92629885708baabea5bbce79fa5a8030f014dbe5c0bf4024031df993dd3ed3a90449db813946cfdfa9c12318096b57eec
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
       "${CMAKE_CURRENT_LIST_DIR}/fix-build-in-windows.patch"
)

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(BUILD_ARCH "Win32")
else()
    message("gsoap only supported Win32")
    set(BUILD_ARCH "Win32")
endif()

# Handle binary files and includes
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/gsoap ${CURRENT_PACKAGES_DIR}/debug/tools)

if (WIN32)
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
file(COPY ${SOURCE_PATH}/gsoap/stdsoap2.h ${SOURCE_PATH}/gsoap/stdsoap2.c ${SOURCE_PATH}/gsoap/stdsoap2.cpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle import files
file(COPY ${SOURCE_PATH}/gsoap/import DESTINATION ${CURRENT_PACKAGES_DIR}/share/gsoap)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt ${SOURCE_PATH}/INSTALL.txt ${SOURCE_PATH}/README.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/gsoap)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/gsoap/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/gsoap/copyright)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/gsoap/INSTALL.txt ${CURRENT_PACKAGES_DIR}/share/gsoap/install)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/gsoap/README.txt ${CURRENT_PACKAGES_DIR}/share/gsoap/readme) 

vcpkg_copy_pdbs()