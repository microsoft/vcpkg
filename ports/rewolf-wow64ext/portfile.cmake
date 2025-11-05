vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rwfpl/rewolf-wow64ext
    REF "v${VERSION}"
    SHA512 bbd96200bb7ba581ce58c3935dff8f1cf336b58f88139ba53511fc9f9f3c98fc030db93b0586011a8afeb07a87b719a15498db2696c567beb4c6b55009c77e47
    HEAD_REF main
)

vcpkg_msbuild_install(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH "src/wow64ext.sln"
)

file(
    INSTALL        "${SOURCE_PATH}/src/wow64ext.h"
    DESTINATION    "${CURRENT_PACKAGES_DIR}/include/wow64ext.h"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/lgpl-3.0.txt")
