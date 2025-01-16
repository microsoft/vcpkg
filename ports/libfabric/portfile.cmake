if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ofiwg/libfabric
    REF v${VERSION}
    SHA512 8242d1eec22a066b65cb99f5b96da44ce19c1dcb3db15238495b28147e8bcee70f6c0eaf5f72e1dc9e004809114a5f96ee696b9e5fc8bd9c07177b9916e35d05
    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH libfabric.vcxproj
        RELEASE_CONFIGURATION Release-v142
        DEBUG_CONFIGURATION Debug-v142
        OPTIONS
            "/p:SolutionDir=${SOURCE_PATH}"
    )
    file(COPY "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/libfabric")

else()
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
        OPTIONS
            --with-uring=no
    )
    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
