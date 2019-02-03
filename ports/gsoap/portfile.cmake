include(vcpkg_common_functions)
set(GSOAP_VERSION 2.8)
set(GSOAP_SUB_VERSION .78)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/gsoap-${GSOAP_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://ayera.dl.sourceforge.net/project/gsoap2/gsoap-${GSOAP_VERSION}/gsoap_${GSOAP_VERSION}${GSOAP_SUB_VERSION}.zip"
    FILENAME "gsoap_${GSOAP_VERSION}${GSOAP_SUB_VERSION}.zip"
    SHA512 c115044d2662c2dd355c4756a974a0013b7213dd28c536aba179e53c19466279bfa34ce16b4426db5aa7a24d94c18e0ed7e7cdf05e799bf89f7b54031aa0874e
)
vcpkg_extract_source_archive(${ARCHIVE})

# Handle binary files and includes
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/gsoap/win32 ${CURRENT_PACKAGES_DIR}/tools/gsoap/macosx)
file(COPY ${SOURCE_PATH}/gsoap/bin/win32/soapcpp2.exe ${SOURCE_PATH}/gsoap/bin/win32/wsdl2h.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/gsoap/win32)
file(COPY ${SOURCE_PATH}/gsoap/bin/macosx/soapcpp2 ${SOURCE_PATH}/gsoap/bin/macosx/wsdl2h DESTINATION ${CURRENT_PACKAGES_DIR}/tools/gsoap/macosx)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/gsoap/stdsoap2.h ${SOURCE_PATH}/gsoap/stdsoap2.c ${SOURCE_PATH}/gsoap/stdsoap2.cpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt ${SOURCE_PATH}/INSTALL.txt ${SOURCE_PATH}/README.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/gsoap)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/gsoap/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/gsoap/copyright)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/gsoap/INSTALL.txt ${CURRENT_PACKAGES_DIR}/share/gsoap/install)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/gsoap/README.txt ${CURRENT_PACKAGES_DIR}/share/gsoap/readme)