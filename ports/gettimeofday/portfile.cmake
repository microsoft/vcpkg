include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/gettimeofday)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  message(STATUS "Warning: Dynamic building not supported yet. Building static.")
  set(VCPKG_LIBRARY_LINKAGE static)
endif()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/gettimeofday.c DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/gettimeofday.h DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/gettimeofday RENAME copyright)
