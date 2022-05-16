vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/qpid-proton
    REF fee5e94afb83b92ffa60a6f815d5102a67915166 # 0.37.0
    SHA512 e9fbd02444dd073908186e6873b4e230e0a5971929e9b1a49758240d166f6da4e6c88d701c66d5e5539bea0beca380c763bffcef5b0e1ed5f9fc2691f5f86559 
    HEAD_REF next
    PATCHES fix-dependencies.patch
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
        -DBUILD_GO=no
        -DCMAKE_DISABLE_FIND_PACKAGE_CyrusSASL=ON
        -DENABLE_JSONCPP=ON
        -DENABLE_LINKTIME_OPTIMIZATION=OFF
        -DLIB_SUFFIX=
        -DENABLE_WARNING_ERROR=OFF
        -DENABLE_BENCHMARKS=OFF
        -DENABLE_FUZZ_TESTING=OFF
        -DBUILD_TESTING=OFF
        -DCMAKE_INSTALL_RPATH=${rpath}
        -DPython_EXECUTABLE=${PYTHON3}
)

vcpkg_cmake_install()

# qpid-proton installs tests into share/proton; this is not desireable
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/proton")

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME Proton
    CONFIG_PATH lib/cmake/Proton
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)
vcpkg_cmake_config_fixup(
    PACKAGE_NAME ProtonCpp
    CONFIG_PATH lib/cmake/ProtonCpp
)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/proton/version.h" "#define PN_INSTALL_PREFIX \"${CURRENT_PACKAGES_DIR}\"" "")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)
