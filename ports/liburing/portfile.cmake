vcpkg_fail_port_install(MESSAGE "'${PORT}' is for Linux" ON_TARGET "windows" "uwp" "osx" "ios" "android")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO axboe/liburing
    REF liburing-2.0
    SHA512 8a7b37600246d44a94d3fed1ca4bb60e76f9ddc60bd3c237e600b60e77961a1125c8a1f230cb7569f959acf10b68b91aafb4935c1c2fd13d5df7373b374e47f5
    HEAD_REF master
    PATCHES
        fix-configure.patch     # ignore unsupported options
        fix-spec-version.patch  # update version value for pkgconfig(.pc) files
)

# note: check ${SOURCE_PATH}/liburing.spec before updating configure options
vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    COPY_SOURCE
    NO_DEBUG
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(INSTALL ${SOURCE_PATH}/LICENSE 
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/liburing.a
                ${CURRENT_PACKAGES_DIR}/lib/liburing.a
    )
else()
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/liburing.so
                ${CURRENT_PACKAGES_DIR}/debug/lib/liburing.so.2
                ${CURRENT_PACKAGES_DIR}/debug/lib/liburing.so.2.0.0
                ${CURRENT_PACKAGES_DIR}/lib/liburing.so
                ${CURRENT_PACKAGES_DIR}/lib/liburing.so.2
                ${CURRENT_PACKAGES_DIR}/lib/liburing.so.2.0.0
    )
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/man)
