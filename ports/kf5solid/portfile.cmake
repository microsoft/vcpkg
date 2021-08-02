vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/solid
    REF v5.84.0
    SHA512 b6452e56c6029289450850c1fcfff96da0005f8dfa03f1817754910945e3ccadd8502e330a4484a5c5e9a8d5525838c8090268bb083639062dfca7176852c159
    HEAD_REF master
)

if(VCPKG_TARGET_IS_OSX)
     # In Darwin platform, there can be an old version of `bison`, 
     # Which can't be used for `gst-build`. It requires 2.4+
     vcpkg_find_acquire_program(BISON)
     execute_process(
         COMMAND ${BISON} --version
         OUTPUT_VARIABLE BISON_OUTPUT
     )
     string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" BISON_VERSION "${BISON_OUTPUT}")
     set(BISON_MAJOR ${CMAKE_MATCH_1})
     set(BISON_MINOR ${CMAKE_MATCH_2})
     message(STATUS "Using bison: ${BISON_MAJOR}.${BISON_MINOR}.${CMAKE_MATCH_3}")
     if(NOT (BISON_MAJOR GREATER_EQUAL 2 AND BISON_MINOR GREATER_EQUAL 4))
         message(WARNING "${PORT} requires bison version greater than one provided by macOS, please use \`brew install bison\` to install a newer bison.")
     endif()
endif()

vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(FLEX)

get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY )
get_filename_component(BISON_DIR "${BISON}" DIRECTORY )

vcpkg_add_to_path(PREPEND "${FLEX_DIR}")
vcpkg_add_to_path(PREPEND "${BISON_DIR}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS 
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5Solid)
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/etc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
# solid-hardware and solid-power are a non-dev tools allowing to list hardware and power managament status of one's system. No need to keep them.
file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/solid-hardware5${VCPKG_HOST_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/debug/bin/solid-hardware5${VCPKG_HOST_EXECUTABLE_SUFFIX}")
file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/solid-power${VCPKG_HOST_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/debug/bin/solid-power${VCPKG_HOST_EXECUTABLE_SUFFIX}")
file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/qml" "${CURRENT_PACKAGES_DIR}/debug/qml")
file(RENAME "${CURRENT_PACKAGES_DIR}/lib/qml" "${CURRENT_PACKAGES_DIR}/qml")

file(INSTALL "${SOURCE_PATH}/LICENSES/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
