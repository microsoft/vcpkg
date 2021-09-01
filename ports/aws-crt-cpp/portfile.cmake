vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-crt-cpp
    REF 88b476c3be22cb46f09574389e6ecebe26c489bf # v0.15.0
    SHA512 cb9c249496fd41fda1efb9330e823d8b965adca6c8f372a50fe97eda821e277780bf9af8f5977102c44121568993cca55edbb750967b41f323e07e06a93c50a8
    PATCHES
          fix-cmake-target-path.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_DEPS=OFF
        -DCMAKE_MODULE_PATH=${CURRENT_INSTALLED_DIR}/share/aws-c-common # use extra cmake files
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/aws-crt-cpp/cmake)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/bin
    ${CURRENT_PACKAGES_DIR}/debug/bin
	${CURRENT_PACKAGES_DIR}/debug/include
	${CURRENT_PACKAGES_DIR}/debug/lib/aws-crt-cpp
	${CURRENT_PACKAGES_DIR}/lib/aws-crt-cpp
)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
