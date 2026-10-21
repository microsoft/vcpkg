vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bloomberg/ntf-core
    REF "${VERSION}"
    SHA512 f30ffc438c656e5bbababa87c8dfe40ac35ffd0962b6fba26c41246aeedc883a4949a3c19ee941cf9d7a54c504d8feb3dcd46b2eb9f4078dcb91e8cb4c60d614
    HEAD_REF main
    PATCHES dont-use-lib64.patch
)

# ntf-core requires debugger information to for dev tooling purposes, so we just fake it
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        "-DNTF_BUILD_WITH_USAGE_EXAMPLES=0"
        "-DNTF_TOOLCHAIN_DEBUGGER_PATH=NOT-FOUND"
        -DNTF_BUILD_SYSTEM=ON
)

vcpkg_cmake_build()

vcpkg_cmake_install()

function(fix_pkgconfig_ufid lib_dir ufid pc_name)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/${lib_dir}/pkgconfig/${pc_name}.pc" "/${ufid}" "")
    if ("${ufid}" MATCHES opt)
        set(build_mode "release")
    else()
        set(build_mode "debug")
    endif()

    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/${lib_dir}/cmake/${pc_name}/${pc_name}-Targets-${build_mode}.cmake" "/${ufid}" "")
endfunction()

function(fix_install_dir lib_dir ufid)
    message(STATUS "Fixing ufid layout for ${CURRENT_PACKAGES_DIR}/${lib_dir}/${ufid}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/${lib_dir}/${ufid}" "${CURRENT_PACKAGES_DIR}/tmp")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/${lib_dir}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/tmp" "${CURRENT_PACKAGES_DIR}/${lib_dir}")

    fix_pkgconfig_ufid("${lib_dir}" "${ufid}" "nts")
    fix_pkgconfig_ufid("${lib_dir}" "${ufid}" "ntc")
endfunction()

fix_install_dir("lib" "opt_exc_mt")
fix_install_dir("debug/lib" "dbg_exc_mt")

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake" PACKAGE_NAME nts)
file(RENAME "${CURRENT_PACKAGES_DIR}/share/nts" "${CURRENT_PACKAGES_DIR}/share/nts_original")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/nts_original/ntc" "${CURRENT_PACKAGES_DIR}/share/ntc")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/nts_original/nts" "${CURRENT_PACKAGES_DIR}/share/nts")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/nts_original")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
vcpkg_fixup_pkgconfig()

# Usage
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

