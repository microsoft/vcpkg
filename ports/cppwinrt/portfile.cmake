include(vcpkg_common_functions)
find_program(GIT git)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/cppwinrt-fall_2017_creators_update_for_vs_15.3)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Microsoft/cppwinrt/archive/fall_2017_creators_update_for_vs_15.3.tar.gz"
    FILENAME "fall_2017_creators_update_for_vs_15.3.tar.gz"
    SHA512  e3f987ed3f3dce019b8bf9f5451e53b42357473a003b8c14f9009e1848ee0463286bd46fdc3c739c8f7c2d232707e8018f5c087ffae784c745d51a8143f9a294
)
vcpkg_extract_source_archive(${ARCHIVE})

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/license DESTINATION ${CURRENT_PACKAGES_DIR}/share/cppwinrt/license.txt)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cppwinrt/license.txt ${CURRENT_PACKAGES_DIR}/share/cppwinrt/copyright)

# Copy the cppwinrt header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/10.0.16299.0/winrt/*)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/winrt)
