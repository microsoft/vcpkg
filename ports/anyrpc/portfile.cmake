include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sgieseking/anyrpc
    REF bfd50aa6dd620066ed308258599127cd46be818b
    SHA512 604e92a2a2936fb95e74e05dd1ac578e67e2877357443d83f8fac319ab244a27d1fac2ebd8bcd9ac8108e7a198752776974027b8f020643bb039b5f84406049b
    HEAD_REF master
    PATCHES "arm_endian_detection.patch"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ANYRPC_LIB_BUILD_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
    -DBUILD_EXAMPLES=OFF
    -DBUILD_TESTS=OFF
    -DBUILD_WITH_LOG4CPLUS=OFF
    -DANYRPC_LIB_BUILD_SHARED=${ANYRPC_LIB_BUILD_SHARED}
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/license DESTINATION ${CURRENT_PACKAGES_DIR}/share/anyrpc RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()
