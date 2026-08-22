vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/solid
    REF "v${VERSION}"
    SHA512 67d22f9da0646e9e98c029e9beec73705582d9bf946c1330166c168f7216113786a3a1ae81c88ad3886244147d48a655c9a938d8700ee39414c1d575c0949959
    HEAD_REF master
    PATCHES
        001_fix_libmount.patch
        002_fix_imobile.patch
        003_libmount.patch
)
# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

if(VCPKG_TARGET_IS_OSX)
    # On Darwin platform, the bundled version of 'bison' may be too old (< 3.0).
    vcpkg_find_acquire_program(BISON)
    execute_process(
        COMMAND "${BISON}" --version
        OUTPUT_VARIABLE BISON_OUTPUT
    )
    string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" BISON_VERSION "${BISON_OUTPUT}")
    set(BISON_MAJOR ${CMAKE_MATCH_1})
    set(BISON_MINOR ${CMAKE_MATCH_2})
    message(STATUS "Using bison: ${BISON_MAJOR}.${BISON_MINOR}.${CMAKE_MATCH_3}")
    if(NOT (BISON_MAJOR GREATER_EQUAL 3 AND BISON_MINOR GREATER_EQUAL 0))
        message(WARNING "${PORT} requires bison version greater than one provided by macOS, please use \`brew install bison\` to install a newer bison.")
    endif()
endif()

vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(FLEX)

get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY)
get_filename_component(BISON_DIR "${BISON}" DIRECTORY)

vcpkg_add_to_path(PREPEND "${FLEX_DIR}")
vcpkg_add_to_path(PREPEND "${BISON_DIR}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        libmount    CMAKE_REQUIRE_FIND_PACKAGE_LibMount
        imobile     CMAKE_REQUIRE_FIND_PACKAGE_IMobileDevice
        imobile     CMAKE_REQUIRE_FIND_PACKAGE_PList
    INVERTED_FEATURES
        libmount    CMAKE_DISABLE_FIND_PACKAGE_LibMount
        imobile     CMAKE_DISABLE_FIND_PACKAGE_IMobileDevice
        imobile     CMAKE_DISABLE_FIND_PACKAGE_PList
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTING=OFF
        -DKDE_INSTALL_QMLDIR=qml
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5Solid)
vcpkg_copy_pdbs()

vcpkg_copy_tools(
    TOOL_NAMES solid-hardware5
    AUTO_CLEAN
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # Until https://github.com/microsoft/vcpkg/pull/34091
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
