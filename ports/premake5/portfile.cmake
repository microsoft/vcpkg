set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/premake/premake-core/releases/download/v5.0.0-alpha15/premake-5.0.0-alpha15-src.zip"
    FILENAME "premake-5.0.0-alpha15-src.zip"
    SHA512 1d9e89f77224d1fc191fec55226e13bf3a5c07d310fa79a4d90b284872ec7c52fb68f8e51874c7f9a97e44bc9af35b9fd781b7b06b9268015c5448c49506e9a7
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_install_msbuild(
	SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH build/vs2015/Premake5.vcxproj
    )
else()
    if(VCPKG_TARGET_IS_OSX)
        set(PROJECT_SUBPATH "build/gmake2.macosx/")
    else()
        set(PROJECT_SUBPATH "build/gmake2.unix/")
    endif()

    vcpkg_configure_make(
        SKIP_CONFIGURE
        NO_DEBUG
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH ${PROJECT_SUBPATH}
    )
    vcpkg_build_make(TARGET "")

    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/premake5)
    file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/bin/release/premake5 DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
