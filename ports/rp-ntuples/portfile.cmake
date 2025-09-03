vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RPeschke/ntuples
    REF "v${VERSION}"
    SHA512 0cd390e79640f0b03b5ac7b58ab52996a0a69f13cd52b404acf06601c2cf5788fe6ef8c082c35ed734fa4094a0b9543a6c07a1f6deaffd8a69475abbae7268dc
)

file(INSTALL "${SOURCE_PATH}/core/include" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

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
