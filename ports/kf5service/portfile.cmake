vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kservice
    REF v5.84.0
    SHA512 3867da989c8f70fccba63d91aeb0038ad6345e66ca7df6003f968628e4a54e076e9686acb501940ef8f540c39d5f1a70a949cbfdd1caa34e6c4d51daebff418d
    HEAD_REF master
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

get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY)
get_filename_component(BISON_DIR "${BISON}" DIRECTORY)

vcpkg_add_to_path(PREPEND "${FLEX_DIR}")
vcpkg_add_to_path(PREPEND "${BISON_DIR}")

vcpkg_cmake_configure(
    DISABLE_PARALLEL_CONFIGURE
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5Service)
vcpkg_copy_pdbs()

vcpkg_copy_tools(
     TOOL_NAMES kbuildsycoca5
     AUTO_CLEAN
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")	
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LICENSES/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")