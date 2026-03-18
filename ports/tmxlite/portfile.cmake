vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fallahn/tmxlite
    REF "v${VERSION}"
    HEAD_REF master
    SHA512 323b8ce20c4d2c7dd98c96ddb4d4d3ba6a3862dbda1e7880086cb493b22e79f1891dda6a4d3145de44b78dfa6258ded366e32f31781f08b1657a1da080013415
    PATCHES
        dependencies.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" TMXLITE_STATIC_LIB)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/tmxlite"
    OPTIONS
        -DTMXLITE_STATIC_LIB=${TMXLITE_STATIC_LIB}
        -DUSE_EXTLIBS=ON
        -DPKGCONF_REQ_PUB=pugixml
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

set(STATIC_POSTFIX "")
if(TMXLITE_STATIC_LIB)
    set(STATIC_POSTFIX "-s")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/tmxlite.pc" "-ltmxlite" "-ltmxlite${STATIC_POSTFIX}")
endif()

if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/tmxlite.pc" "-ltmxlite" "-ltmxlite${STATIC_POSTFIX}-d")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
