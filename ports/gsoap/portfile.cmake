message(FATAL_ERROR "gsoap does not offer permanent public downloads of its sources; all versions except the latest are removed from sourceforge. Therefore, vcpkg cannot support this library directly in the central catalog. If you would like to use gsoap, you can use this port as a starting point (${CMAKE_CURRENT_LIST_DIR}) and update it to use a permanent commercial copy or the latest public download. Do not report issues with this library to the vcpkg GitHub.")

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gsoap2
    REF gsoap-2.8
    FILENAME "gsoap_2.8.112.zip"
    SHA512 0c2562891a738916235f1d4b19d8419d96d0466ca4b729766551183c7b9b90cbe35bbf7fe126b3ea6b18138cbf591c9a9b5b73ddea7152ccdd2f790777c2b6d8
    PATCHES fix-build-in-windows.patch
)

set(BUILD_ARCH "Win32")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/gsoap" "${CURRENT_PACKAGES_DIR}/debug/tools")

if (VCPKG_TARGET_IS_WINDOWS)
     vcpkg_msbuild_install(
        PROJECT_PATH "${SOURCE_PATH}/gsoap/VisualStudio2005/soapcpp2/soapcpp2.sln"
        PLATFORM ${BUILD_ARCH}
        TARGET Build
    )
     vcpkg_msbuild_install(
        PROJECT_PATH "${SOURCE_PATH}/gsoap/VisualStudio2005/wsdl2h/wsdl2h.sln"
        PLATFORM ${BUILD_ARCH}
        TARGET Build
    )
else()
    message(FATAL_ERROR "Sorry but gsoap only can be build in Windows temporary")
endif()


file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")

file(COPY
    "${SOURCE_PATH}/gsoap/stdsoap2.h"
    "${SOURCE_PATH}/gsoap/stdsoap2.c"
    "${SOURCE_PATH}/gsoap/stdsoap2.cpp"
    "${SOURCE_PATH}/gsoap/dom.c"
    "${SOURCE_PATH}/gsoap/dom.cpp"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

file(COPY "${SOURCE_PATH}/gsoap/import" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY "${SOURCE_PATH}/gsoap/custom" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY "${SOURCE_PATH}/gsoap/plugin" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/gsoap/plugin/.deps")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
file(INSTALL "${SOURCE_PATH}/INSTALL.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME install)
file(INSTALL "${SOURCE_PATH}/README.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME readme)
