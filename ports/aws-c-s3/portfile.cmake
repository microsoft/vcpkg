vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-c-s3
    REF d7bfe602d6925948f1fff95784e3613cca6a3900 # v0.2.3
    SHA512 7b4f296533a53728427f76ca31b78abb3ef6830214b08dd068e42752df5abea2244eaca7d0af1248089ab6c0db5ac739ae0d6e1bb2e51d44a6e5edeec5d8062e
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

vcpkg_cmake_config_fixup(CONFIG_PATH lib/aws-c-s3/cmake)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE 
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
endif()

file(REMOVE_RECURSE
	"${CURRENT_PACKAGES_DIR}/debug/include"
	"${CURRENT_PACKAGES_DIR}/debug/lib/aws-c-s3"
	"${CURRENT_PACKAGES_DIR}/lib/aws-c-s3"
	)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
