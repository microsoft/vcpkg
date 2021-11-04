vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/qpid-proton
    REF dc244b1f7e886883a2bb416407f42ba55d0f5f42 # 0.32.0
    SHA512 19f191dd206fd43a8f5b8db95f6ada57bd60b93eb907cf32f463c23cfe8c5f4914c6f4750ebde50c970387fb62baf4451279803eeb000bc8bb5c200692e5d1d7 
    HEAD_REF next
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPYTHON_EXECUTABLE=${PYTHON3}
        -DLIB_SUFFIX=
        -DBUILD_GO=no
        -DBUILD_RUBY=no
        -DBUILD_PYTHON=no
        -DENABLE_JSONCPP=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_CyrusSASL=ON
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)
vcpkg_fixup_pkgconfig()

file(RENAME "${CURRENT_PACKAGES_DIR}/share/proton/LICENSE.txt"
            "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/proton")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/proton/version.h" "#define PN_INSTALL_PREFIX \"${CURRENT_PACKAGES_DIR}\"" "")
