vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsigcplusplus/libsigcplusplus
    REF 7e20b36bddab74faed39aa3768d07fd372fce596
    SHA512 6220a3974ee90afb5028a5b60ffcbff353fffbbfcf1570d8db05b6d91604324a73badcb17c73c852d6c5265e2b31e1c2de1b3ea20c0e60ecdb17ce90c9ca40bd
    HEAD_REF master
    PATCHES 
        disable_tests_enable_static_build.patch
        version.patch
        fix-usage-in-static-build.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/sigc++-3 TARGET_PATH share/sigc++-3)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/sigc++-3.0/include/sigc++config.h" "ifdef BUILD_SHARED" "if 1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
