set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    WINDOWS_USE_MSBUILD
)
vcpkg_cmake_build()

file(GLOB_RECURSE CRTSYS_TEST_DRIVERS
    LIST_DIRECTORIES false
    "${CURRENT_BUILDTREES_DIR}/crtsys_vcpkg_consumer.sys"
    "${CURRENT_BUILDTREES_DIR}/*/crtsys_vcpkg_consumer.sys"
    "${CURRENT_BUILDTREES_DIR}/*/*/crtsys_vcpkg_consumer.sys"
)
if(NOT CRTSYS_TEST_DRIVERS)
    message(FATAL_ERROR
        "The crtsys consumer build did not produce crtsys_vcpkg_consumer.sys."
    )
endif()
