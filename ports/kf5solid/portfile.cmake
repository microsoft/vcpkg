vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/solid
    REF v5.84.0
    SHA512 b6452e56c6029289450850c1fcfff96da0005f8dfa03f1817754910945e3ccadd8502e330a4484a5c5e9a8d5525838c8090268bb083639062dfca7176852c159
    HEAD_REF master
    PATCHES
        fix_config_cmake.patch # https://invent.kde.org/frameworks/solid/-/merge_requests/53
)

if(VCPKG_TARGET_IS_OSX)
    # On Darwin platform, the bundled version of 'bison' may be too old (< 3.0).
    vcpkg_find_acquire_program(BISON)
    execute_process(
        COMMAND ${BISON} --version
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

get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY )
get_filename_component(BISON_DIR "${BISON}" DIRECTORY )

vcpkg_add_to_path(PREPEND "${FLEX_DIR}")
vcpkg_add_to_path(PREPEND "${BISON_DIR}")

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE ${SOURCE_PATH}/.clang-format "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5Solid CONFIG_PATH lib/cmake/KF5Solid)
vcpkg_copy_pdbs()

vcpkg_copy_tools(
      TOOL_NAMES solid-hardware5
      AUTO_CLEAN
 )

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/qml" "${CURRENT_PACKAGES_DIR}/debug/qml")
file(RENAME "${CURRENT_PACKAGES_DIR}/lib/qml" "${CURRENT_PACKAGES_DIR}/qml")

file(INSTALL "${SOURCE_PATH}/LICENSES/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
