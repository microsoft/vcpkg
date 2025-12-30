vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ffmpeg/ffmpeg
    REF "n${VERSION}"
    SHA512 f31769a7ed52865165e7db4a03e9378b3376012b7aaf0bbc022aa76c3e999e71c3927e6eb8639d8681e04e33362dd73eafa9e7c62a3c71599ff78da09f5cee0a
    HEAD_REF master
)

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}/ffbuild")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/ffbuild"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Move the tool to a location where it can be referenced as a host tool
file(INSTALL 
    "${CURRENT_PACKAGES_DIR}/bin/bin2c${VCPKG_HOST_EXECUTABLE_SUFFIX}" 
    DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}"
)

# Clean up
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${SOURCE_PATH}/COPYING.LGPLv2.1" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)