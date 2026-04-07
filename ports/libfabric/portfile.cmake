if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ofiwg/libfabric
    REF v${VERSION}
    SHA512 c35d74a0347c316a1ef2a93afc375b1d472a56783f8515e279084c63eac2a06096bb0102ad919070a75641a0221027245efdb14e616f7888ca6f6685755a5900
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
    vcpkg_make_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTORECONF
        OPTIONS
            --with-uring=no
    )
    vcpkg_make_install()
    vcpkg_fixup_pkgconfig()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
