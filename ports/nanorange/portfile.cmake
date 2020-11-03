# header-only
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tcbrindle/NanoRange
    HEAD_REF master
)

#<tests>
#vcpkg_configure_cmake(
#    SOURCE_PATH ${SOURCE_PATH}
#    PREFER_NINJA
#)
#vcpkg_build_cmake()
#</tests>

# Copy header files
file(COPY ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/nanorange)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/nanorange/LICENSE_1_0.txt ${CURRENT_PACKAGES_DIR}/share/nanorange/copyright)

