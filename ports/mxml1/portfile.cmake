vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO michaelrsweet/mxml
    REF "v${VERSION}"
    SHA512 43e6a92806d9c3f5db39fbf960c15ebfa6d92ef98274b7ce39b57724d6c26ad4362d6d8f3c1023efda92e6a815df068e5038a0cd479562b6be9dbdda8e827a41
    HEAD_REF master
    PATCHES
    0001-win-platform-fix.patch # Issue347
)

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message(WARNING "mxml built as a static library on Windows is not thread-safe.")
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    # Force Z7 debug information format for MSVC builds
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(MXML_VCNET_PROJECT "vcnet/mxmlstat.vcxproj")
    else()
        set(MXML_VCNET_PROJECT "vcnet/mxml1.vcxproj")
        vcpkg_replace_string("${SOURCE_PATH}/${MXML_VCNET_PROJECT}"
            "<DebugInformationFormat>ProgramDatabase</DebugInformationFormat>"
            "<DebugInformationFormat>OldStyle</DebugInformationFormat>"
        )
        vcpkg_replace_string("${SOURCE_PATH}/${MXML_VCNET_PROJECT}"
            "<DebugInformationFormat>EditAndContinue</DebugInformationFormat>"
            "<DebugInformationFormat>OldStyle</DebugInformationFormat>"
        )
        vcpkg_replace_string("${SOURCE_PATH}/${MXML_VCNET_PROJECT}"
            "<MinimalRebuild>true</MinimalRebuild>"
            "<MinimalRebuild>false</MinimalRebuild>"
        )
    endif()

    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "${MXML_VCNET_PROJECT}"
        TARGET Build
    )
    file(INSTALL "${SOURCE_PATH}/mxml.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
else()
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(MXML_SHARED_OPT --disable-shared)
    endif()
    vcpkg_replace_string("${SOURCE_PATH}/Makefile.in"
        "ALLTARGETS	=	$(LIBMXML) testmxml"
        "ALLTARGETS =   $(LIBMXML)"
    )#remove test target
    vcpkg_make_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        COPY_SOURCE
        OPTIONS
        ${MXML_SHARED_OPT}
        "--prefix=${CURRENT_PACKAGES_DIR}"
    )
    vcpkg_make_install()
    vcpkg_fixup_pkgconfig()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
