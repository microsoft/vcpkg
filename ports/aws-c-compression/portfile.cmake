vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-c-compression
    REF b517b7decd0dac30be2162f5186c250221c53aff # v0.2.16
    SHA512 482cfaa85a3edddb4a266e6a8f2f0ca534461ecb20910bfd76fac82f0d9dc4b5663500134dca2961b805a29b64058266f3c34abebabdb274689c091d27f9fb5e
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

vcpkg_cmake_config_fixup(CONFIG_PATH lib/aws-c-compression/cmake)

file(REMOVE_RECURSE
	"${CURRENT_PACKAGES_DIR}/debug/include"
	"${CURRENT_PACKAGES_DIR}/debug/lib/aws-c-compression"
	"${CURRENT_PACKAGES_DIR}/lib/aws-c-compression"
)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
