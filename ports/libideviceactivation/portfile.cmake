include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libideviceactivation
    REF v1.2.68
    SHA512 c2742bba2d90c21e853255c9ef1b9a63560c3e65541a0a3daaace9b0c48d236b7947008dbcd6e42622251015b686758ebc6b564e379d831cb4f52af812430140
    HEAD_REF msvc-master
)

if(${VCPKG_LIBRARY_LINKAGE} MATCHES dynamic)
    vcpkg_apply_patches(
        SOURCE_PATH ${SOURCE_PATH}
        PATCHES
            libcurl_imp.patch)
else()
    vcpkg_apply_patches(
        SOURCE_PATH ${SOURCE_PATH}
        PATCHES
            libcurl_d.patch)
endif()

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH libideviceactivation.sln
    INCLUDES_SUBPATH include
    LICENSE_SUBPATH COPYING
    USE_VCPKG_INTEGRATION
    ALLOW_ROOT_INCLUDES
)

file(REMOVE ${CURRENT_PACKAGES_DIR}/include/Makefile.am)
