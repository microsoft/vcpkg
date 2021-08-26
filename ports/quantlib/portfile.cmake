vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lballabio/QuantLib
    REF QuantLib-v1.22
    SHA512 279c2e9273dd0fbc03d19ac19814e8a3b5544545cc1441982232f89bd313fe76b6e252dbcae8a3d146ecc4f1d1e64632ac412096b89da882ba879a66776fdb91
    HEAD_REF master
    PATCHES
        disable-examples-tests.patch
        fix-mac-build.patch # fixed in next release
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" USE_BOOST_DYNAMIC_LIBRARIES)

set(QL_MSVC_RUNTIME ${VCPKG_LIBRARY_LINKAGE})

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

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
