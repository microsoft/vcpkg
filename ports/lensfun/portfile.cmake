vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "uwp")

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lensfun/lensfun
    REF 9e79aa406133a4166a31099d1d19b879c833956e 
    SHA512 6fa4c2815d24b064ca50a41dd6a28d5813a9b3e3137b3a5ad1aa83bf6c9e858e892fa878b3005c9497583ec43e7bb5118095d3326b21fdc3fc107b201d32c62a
    HEAD_REF master
    PATCHES fix-build-error.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(BUILD_STATIC ON)
else()
    set(BUILD_STATIC OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJIA
    OPTIONS
        -DBUILD_STATIC=${BUILD_STATIC}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)