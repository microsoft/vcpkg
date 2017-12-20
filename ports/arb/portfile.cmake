if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fredrik-johansson/arb
    REF 2.11.1
    SHA512 7a014da5208b55f20c7a3cd3eb51070b09ae107b04cbbd6329925780c2ab4d7c38e1fb3619f21456fa806939818370fcae921f59eb013661b6bdd3d0971e3353
    HEAD_REF master
)

file(REMOVE ${SOURCE_PATH}/CMakeLists.txt)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()


# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/arb RENAME copyright)

# Remove duplicate headers
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
