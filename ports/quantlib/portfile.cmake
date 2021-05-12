vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lballabio/QuantLib
    REF f47242c966d191e1b542162b1f2d726615bdba89
    SHA512 9b16f4d5c0bedc53d755ea4ac575e682dca4b4436ef4803e269cda8d2c3843ffa5b1e3d333270370b3133c7abfa465cab900055de30a6fcb52785a6afa15a0f4
    HEAD_REF master
    PATCHES
        disable-examples-tests.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" USE_BOOST_DYNAMIC_LIBRARIES)

set(QL_MSVC_RUNTIME ${VCPKG_LIBRARY_LINKAGE})

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# TODO: Fix it in the upstream
vcpkg_replace_string(
    "${SOURCE_PATH}/ql/userconfig.hpp"
    "//#    define QL_USE_STD_UNIQUE_PTR"
    "#    define QL_USE_STD_UNIQUE_PTR"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DUSE_BOOST_DYNAMIC_LIBRARIES=${USE_BOOST_DYNAMIC_LIBRARIES}
        -DMSVC_RUNTIME=${QL_MSVC_RUNTIME}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.TXT ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
