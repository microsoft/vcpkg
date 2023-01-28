vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-c-sdkutils
    REF 208a701fa01e99c7c8cc3dcebc8317da71362972 # v0.1.17
    SHA512 a3d06c4f862e043b5dcfe1b95be43e25c50937558c157422520e77c381d3f570dc00997e79a7eff9583283ff2fb12e97373ce9260e5c6094e7d7d65da863980c
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

vcpkg_cmake_config_fixup(CONFIG_PATH lib/aws-c-sdkutils/cmake)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE 
        "${CURRENT_PACKAGES_DIR}/bin" 
        "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
endif()

file(REMOVE_RECURSE
	"${CURRENT_PACKAGES_DIR}/debug/include"
	"${CURRENT_PACKAGES_DIR}/debug/lib/aws-c-sdkutils"
	"${CURRENT_PACKAGES_DIR}/lib/aws-c-sdkutils"
	)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
