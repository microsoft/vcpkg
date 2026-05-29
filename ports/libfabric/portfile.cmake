if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ofiwg/libfabric
    REF v${VERSION}
    SHA512 a59e149e567bb34715145d9974fd4d3da49e3ba25cbf5a568388b9724ad942bf3dcbbdde530522ef1dc5094987b6e3a350a5debec34bb5880f6a096c504f4770
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
