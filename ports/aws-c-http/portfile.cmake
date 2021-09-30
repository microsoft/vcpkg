vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-c-http
    REF 6ff61d621c374ab763f94584d26b1d29baa81c2e # v0.6.5
    SHA512 91a5f3c18e6c8d14368ad2b7275a1ebcc6398758f6b1f87ba6199998390a26e768e25c16b27f589e35371f7304b6784cfc21699ff724c811135f2f73732fe85b
    HEAD_REF master
    PATCHES fix-cmake-target-path.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        "-DCMAKE_MODULE_PATH=${CURRENT_INSTALLED_DIR}/share/aws-c-common" # use extra cmake files
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/aws-c-http/cmake)

vcpkg_copy_tools(
    TOOL_NAMES elasticurl
    AUTO_CLEAN
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE 
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
endif()

file(REMOVE_RECURSE
	"${CURRENT_PACKAGES_DIR}/debug/include"
	"${CURRENT_PACKAGES_DIR}/debug/lib/aws-c-http"
	"${CURRENT_PACKAGES_DIR}/lib/aws-c-http"
	)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
