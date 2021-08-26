vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO msteinbeck/tinyspline
    REF 0.2.0
    SHA512 50cf4927b311eeca6de7954f1b8d585cbf71355f5e5b0aac2f92f5f4ba37986df16eb3251f94a2304d27dab27d4f6b838b410f53e30de28bab53facf194eb640
    HEAD_REF master
    PATCHES
        "001-do-not-treat-warnings-as-errors.patch"
)


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/src
    PREFER_NINJA
)

vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/tinyspline/copyright COPYONLY)
