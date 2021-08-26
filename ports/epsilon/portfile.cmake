vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO epsilon-project/epsilon
    REF 0.9.2
    FILENAME "epsilon-0.9.2.tar.gz"
    SHA512 95f427c68a4a4eb784f7d484d87fc573133983510f6b030663f88955e2446490a07b1343ae4668251b466f67cf9a79bd834b933c57c5ed12327f32174f20ac0f
    PATCHES
        0001-VS2015-provides-snprintf.patch
        0002-Add-CFLAGS-for-CRT-selection-and-warning-supression.patch
        0003-Fix-build-error.patch
)

if (VCPKG_CRT_LINKAGE STREQUAL static)
    set(CL_FLAGS_REL "/MT /Ox /fp:precise")
    set(CL_FLAGS_DBG "/MTd /Zi")
    set(TARGET_LIB epsilon.lib)
else()
    set(CL_FLAGS_REL "/MD /Ox /fp:precise")
    set(CL_FLAGS_DBG "/MDd /Zi")
    set(TARGET_LIB epsilon_i.lib)
endif()

vcpkg_install_nmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        INSTALLED_ROOT="${CURRENT_INSTALLED_DIR}"
    OPTIONS_DEBUG
        INSTDIR="${CURRENT_PACKAGES_DIR}/debug"
        MSVC_VER=1900
        CRT_FLAGS=${CL_FLAGS_DBG}
        DEBUG=1
        ${TARGET_LIB}
        LIBPATH="${CURRENT_INSTALLED_DIR}/debug/lib/"
    OPTIONS_RELEASE
        INSTDIR="${CURRENT_PACKAGES_DIR}"
        MSVC_VER=1900
        CRT_FLAGS=${CL_FLAGS_REL}
        ${TARGET_LIB}
        LIBPATH="${CURRENT_INSTALLED_DIR}/lib/"
)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
