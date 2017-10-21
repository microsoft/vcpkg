#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO g-truc/gli
    REF 0.8.2.0
    SHA512 c254a4e1497d0add985e4a882c552db99c512cc0e9cc72145d51a6e7deada817d624d9818099a47136a8a3ef1223a26a34e355e3c713166f0bb062e506059834
    HEAD_REF master
)

# Put the license file where vcpkg expects it
# manual.md contains the "licenses" section for the project
file(COPY ${SOURCE_PATH}/manual.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/gli/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/gli/manual.md ${CURRENT_PACKAGES_DIR}/share/gli/copyright)

# Copy the glm header files
file(GLOB HEADER_FILES "${SOURCE_PATH}/gli/*.hpp" "${SOURCE_PATH}/gli/core")
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/gli)
