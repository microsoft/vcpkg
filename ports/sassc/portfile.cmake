vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sass/sassc
    REF 46748216ba0b60545e814c07846ca10c9fefc5b6 # 3.6.1
    SHA512 98c5943ec485251fd5e3f41bcfe80dbbc6e2f334d4b6947895d3821b30009c40fb7cb944403304cede70360a5dd0ac103262644ef37a56e0fa76163657fbcc32
    HEAD_REF master
    PATCHES remove_compiler_flags.patch
)

find_library(LIBSASS_DEBUG sass PATHS "${CURRENT_INSTALLED_DIR}/debug/lib/" NO_DEFAULT_PATH)
find_library(LIBSASS_RELEASE sass PATHS "${CURRENT_INSTALLED_DIR}/lib/" NO_DEFAULT_PATH)
if(VCPKG_TARGET_IS_WINDOWS)
    set(ENV{LIBS} "$ENV{LIBS} -lgetopt")
endif()
vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    OPTIONS
        --with-libsass-include='${CURRENT_INSTALLED_DIR}/include'
    OPTIONS_DEBUG
        --with-libsass-lib='${LIBSASS_DEBUG}'
    OPTIONS_RELEASE
        --with-libsass-lib='${LIBSASS_RELEASE}'
)
vcpkg_install_make(MAKEFILE GNUmakefile)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)