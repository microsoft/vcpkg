include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME MATCHES "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libevent/libevent
    REF release-2.1.8-stable
    SHA512 0d5c872dc797b69ab8ea4b83aebcbac20735b8c6f5adfcc2950aa4d6013d240f5fac3376e817da75ae0ccead50cec0d931619e135a050add438777457b086549
    PATCHES
        "fix-target-files.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DEVENT_INSTALL_CMAKE_DIR:PATH=share/libevent
        -DEVENT__DISABLE_BENCHMARK=ON
        -DEVENT__DISABLE_TESTS=ON
        -DEVENT__DISABLE_REGRESS=ON
        -DEVENT__DISABLE_SAMPLES=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets()
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libevent)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libevent/LICENSE ${CURRENT_PACKAGES_DIR}/share/libevent/copyright)
