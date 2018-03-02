#header-only library
include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO onqtam/doctest
    REF 1.2.7
    SHA512 aa6671eb0ac0a7336ad81dea4d696ce61849ab7eb97d6f0f549446b2ac7538a8cdb0a87b8500b3af41cd3f10672ae13591633b368cbcb901f361f7715f22e4e9
    HEAD_REF master
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/doctest RENAME copyright)

# Copy header file
file(INSTALL ${SOURCE_PATH}/doctest/doctest.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/doctest)
