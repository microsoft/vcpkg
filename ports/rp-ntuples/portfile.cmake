vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RPeschke/ntuples
    REF "v${VERSION}"
    SHA512 591fa37eb77fb793490a34cb7759d8f0d7aaa1f904f9b92d9d03064430cd3adfa7f45eef31b9043b84bf2ff1a480e2c1407a242e604173c795ef97722e061668
)

file(INSTALL "${SOURCE_PATH}/core/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/ntuples")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/ntuples/ntuples-config.cmake"
[[if (TARGET ntuples::ntuples)
  return()
endif()
get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
add_library(ntuples INTERFACE)
add_library(ntuples::ntuples ALIAS ntuples)
target_include_directories(ntuples INTERFACE "${_IMPORT_PREFIX}/include")
target_compile_features(ntuples INTERFACE cxx_std_20)
]])

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE" 
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(WRITE "${CURRENT_PACKAGES_DIR}/share/ntuples/usage"
[[rp-ntuples provides CMake targets:

    find_package(ntuples CONFIG REQUIRED)
    target_link_libraries(main PRIVATE ntuples::ntuples)
]])
