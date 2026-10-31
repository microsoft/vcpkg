vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO michaelrsweet/mxml
    REF "v${VERSION}"
    SHA512 5df2aa25c4263cea5702a3cc8d988e35a851fcdf0840214d4f6fc6c2cc51feeb62c874a97ffaaae8392076515b223985785e1d1a43058fee198b9cf0685f848b

    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    # Force Z7 debug information format for MSVC builds
    vcpkg_replace_string("${SOURCE_PATH}/vcnet/mxml4.vcxproj"
      "<DebugInformationFormat>ProgramDatabase</DebugInformationFormat>"
      "<DebugInformationFormat>OldStyle</DebugInformationFormat>"
    )
    vcpkg_replace_string("${SOURCE_PATH}/vcnet/mxml4.vcxproj"
      "<DebugInformationFormat>EditAndContinue</DebugInformationFormat>"
      "<DebugInformationFormat>OldStyle</DebugInformationFormat>"
    )
    vcpkg_replace_string("${SOURCE_PATH}/vcnet/mxml4.vcxproj"
        "<MinimalRebuild>true</MinimalRebuild>"
        "<MinimalRebuild>false</MinimalRebuild>"
    )

    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "vcnet/mxml4.vcxproj"
        TARGET Build
    )
    file(INSTALL "${SOURCE_PATH}/mxml.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
else()
    vcpkg_make_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        COPY_SOURCE
    )
    vcpkg_make_install()
    vcpkg_fixup_pkgconfig()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
