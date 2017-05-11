# header only
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vinniefalco/Beast
    REF f2d825594ee34ccc1ebc0b231899a1735245778d
    SHA512 21ea2ba77ff8c1dac873e7abd4caa03da50f155c34b39783380d4319c930be02076bf2b7ffcf93a964cac60bfb0a2ec8621156c332adedd3a2af82a27ca50e1a
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/beast RENAME copyright)