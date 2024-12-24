set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sass/sassc
    REF "${VERSION}"
    SHA512 fff3995ce8608bdaed5f4f1352ae4f1f882de58663b932c598d6168df421e4dbf907ec0f8caebb1e56490a71ca11105726f291b475816dd53e705bc53121969f
    HEAD_REF master
    PATCHES remove_compiler_flags.patch
)

find_library(LIBSASS_DEBUG sass PATHS "${CURRENT_INSTALLED_DIR}/debug/lib/" NO_DEFAULT_PATH)
find_library(LIBSASS_RELEASE sass PATHS "${CURRENT_INSTALLED_DIR}/lib/" NO_DEFAULT_PATH)
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(ENV{LIBS} "$ENV{LIBS} -lgetopt")
endif()
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        "--with-libsass-include='${CURRENT_INSTALLED_DIR}/include'"
    OPTIONS_DEBUG
        "--with-libsass-lib='${LIBSASS_DEBUG}'"
    OPTIONS_RELEASE
        "--with-libsass-lib='${LIBSASS_RELEASE}'"
)
vcpkg_install_make(MAKEFILE GNUmakefile)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
