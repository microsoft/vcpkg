vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/tracelogging
    REF v0.3.1
    SHA512 8a34eb7d91b92c36fc0682d45c188361aaffd57b0b8bd62d16b876d3231fc96c5fe3369dc26d23ad2ca4eacda9ac565d04866c4b8b3be1214906c5f939d8a23a
    HEAD_REF master
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"

    OPTIONS
        -DTRACELOGGING_BUILD_TESTS=OFF
        ${OPTIONS}
)

vcpkg_cmake_build()

file(
	INSTALL "${SOURCE_PATH}/LICENSE"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/tracelogging)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")