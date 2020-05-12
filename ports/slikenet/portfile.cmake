vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SLikeSoft/SLikeNet
    REF cca394f05e9e9e3e315a85539e648f267d3f2fcc
    SHA512 410954bda5a7be309eb71c3078f8ea67ff21aae2ce923f01db77b09265969f1350afb45b90194118bfad274f0a36a2d3bbc38d86a15507fdfc4bc8edc4a0204c
    HEAD_REF master
    PATCHES
        fix-install.patch
)
#Uses an outdated OpenSSL version and is in an experimental namespace any way. As such we delete it here
file(REMOVE_RECURSE "${SOURCE_PATH}/Source/src/crypto" "${SOURCE_PATH}/Source/include/slikenet/crypto")

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(SLIKENET_ENABLE_STATIC TRUE)
    set(SLIKENET_ENABLE_DLL FALSE)
else()
    set(SLIKENET_ENABLE_STATIC FALSE)
    set(SLIKENET_ENABLE_DLL TRUE)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSLIKENET_ENABLE_DLL=${SLIKENET_ENABLE_DLL}
        -DSLIKENET_ENABLE_STATIC=${SLIKENET_ENABLE_STATIC}
        -DSLIKENET_ENABLE_SAMPLES=FALSE
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)