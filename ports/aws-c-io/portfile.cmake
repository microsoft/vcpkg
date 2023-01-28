vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-c-io
    REF b52181af655c090713fe01f14d7ccb95aab8dec5 # v0.13.14
    SHA512 e4bfe27e44117ba0de16e8ad8f6826dea1070a8d0c849783415d359a0ecec185e6c90aa0a0231ff03ddfc257efcba4d2ffccbb17d502078bf89b7a53742743d1
    HEAD_REF master
    PATCHES fix-cmake-target-path.patch
		fix-cmake-config-file.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_MODULE_PATH=${CURRENT_INSTALLED_DIR}/share/aws-c-common" # use extra cmake files
        -DBUILD_TESTING=FALSE
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/aws-c-io/cmake)

file(REMOVE_RECURSE
	"${CURRENT_PACKAGES_DIR}/debug/include"
	"${CURRENT_PACKAGES_DIR}/debug/lib/aws-c-io"
	"${CURRENT_PACKAGES_DIR}/lib/aws-c-io"
	)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE	"${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
