include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/utfz-1.2)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/IMQS/utfz/archive/v1.2.zip"
    FILENAME "utfz-1.2.zip"
    SHA512 a3bef8f769c7eb15fbd3a4c3c64f2e70666bfd305ad3c24ef676c7f5a428d95fdb8dcfe18cb5bfa072069e9368a29bf375848f9a775e60bec2eae7ffa5662b55
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

# Copy the include file
file(COPY ${SOURCE_PATH}/utfz.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/license DESTINATION ${CURRENT_PACKAGES_DIR}/share/utfz)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/utfz/license ${CURRENT_PACKAGES_DIR}/share/utfz/copyright)
