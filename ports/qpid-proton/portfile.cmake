vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/qpid-proton
    REF "${VERSION}"
    SHA512 38659682cc86bf0c910e2a707a5b166b3a7d0fb70fd83d6c5ebcaca53b2cd5a478adf36958d2c4c55a2ea6afcb9b457a12006a7967efae6ca2d0663c0febbc58
    HEAD_REF next
    PATCHES
        fix-dependencies.patch
)

file(REMOVE "${SOURCE_PATH}/tools/cmake/Modules/FindPython.cmake")
file(REMOVE "${SOURCE_PATH}/tools/cmake/Modules/FindOpenSSL.cmake")
file(REMOVE "${SOURCE_PATH}/tools/cmake/Modules/FindJsonCpp.cmake")

vcpkg_find_acquire_program(PYTHON3)

if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    set(rpath "@loader_path")
else()
    set(rpath "\$ORIGIN")
endif()
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE # It may cause call CHECK_LIBRARY_EXISTS before call project to set the language
    OPTIONS
        -DBUILD_BINDINGS=cpp
        -DCMAKE_DISABLE_FIND_PACKAGE_CyrusSASL=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_SWIG=ON
        -DENABLE_JSONCPP=ON
        -DENABLE_LINKTIME_OPTIMIZATION=OFF
        -DENABLE_OPENTELEMETRYCPP=OFF
        -DLIB_SUFFIX=
        -DENABLE_WARNING_ERROR=OFF
        -DENABLE_BENCHMARKS=OFF
        -DENABLE_FUZZ_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DCMAKE_INSTALL_RPATH=${rpath}
        -DPython_EXECUTABLE=${PYTHON3}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# qpid-proton installs tests into share/proton; this is not desireable
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/proton")

vcpkg_cmake_config_fixup(
    PACKAGE_NAME proton
    CONFIG_PATH lib/cmake/Proton
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)
vcpkg_cmake_config_fixup(
    PACKAGE_NAME protoncpp
    CONFIG_PATH lib/cmake/ProtonCpp
)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/proton/version.h" "#define PN_INSTALL_PREFIX \"${CURRENT_PACKAGES_DIR}\"" "")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
