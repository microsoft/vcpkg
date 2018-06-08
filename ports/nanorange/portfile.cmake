# header-only
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tcbrindle/NanoRange
    REF 60be620449c762794b0664e4232c461ed4a51d82
    SHA512 9f03597c80a4fa2d287dca571cdfbddc9d93ee4402bf73d9dcb3dbc45b93931b0f028e068ff2d165a9efdfdb5761223139f7f0966d405689dcc1794710281c80
    HEAD_REF master
)

#<tests>
#vcpkg_configure_cmake(
#    SOURCE_PATH ${SOURCE_PATH}
#    PREFER_NINJA
#)
#vcpkg_build_cmake()
#</tests>

file(COPY ${SOURCE_PATH}/single_include/nanorange.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/nanorange)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/nanorange/LICENSE_1_0.txt ${CURRENT_PACKAGES_DIR}/share/nanorange/copyright)

