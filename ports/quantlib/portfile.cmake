include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lballabio/QuantLib
    REF f09141b5cce9134c0bcdbaf36e81359e6ba30705
    SHA512 d4b19d33594a7072a0d90b7eac3d74fb27c526269713a9223b84c0451b1e06a58f0c98350305d68a55086d1971260ff249049112aaadea59397ec195a3291490
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
