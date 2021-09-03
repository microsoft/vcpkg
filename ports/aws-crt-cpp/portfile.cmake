vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-crt-cpp
    REF 88b476c3be22cb46f09574389e6ecebe26c489bf # v0.15.0
    SHA512 cfcacd81818ae3df6a608f71e314675823eddfe017783d97bb64c02f679989ccc2fb56c0af080a8c16df03df09766ecf6267371947c8c275373ce1caf5e53e70
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
