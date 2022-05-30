vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jemalloc/jemalloc
    REF 54eaed1d8b56b1aa528be3bdd1877e59c56fa90c
    SHA512 527bfbf5db9a5c2b7b04df4785b6ae9d445cff8cb17298bf3e550c88890d2bd7953642d8efaa417580610508279b527d3a3b9e227d17394fd2013c88cb7ae75a
    HEAD_REF master
    PATCHES
        fix-configure-ac.patch
)
if(VCPKG_TARGET_IS_WINDOWS)
    set(opts "ac_cv_search_log=none required")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    NO_WRAPPERS
    OPTIONS ${opts}
)

vcpkg_install_make()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(COPY "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/jemalloc")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/jemalloc/COPYING" "${CURRENT_PACKAGES_DIR}/share/jemalloc/copyright")
