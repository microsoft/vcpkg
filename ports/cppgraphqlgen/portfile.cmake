include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/cppgraphqlgen
    REF c68c141b1ab091f4cabad78f0762bb1d6201199f
    SHA512 3a382a0fe79c6ad59f2be6b3445b46a580cf6beb837b3c959879d1263176de2316d8a3555fbc06eb82f589b1c6886e2154d871725e7c820e931a2172bfd51f11
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_TESTS=OFF -DUPDATE_SAMPLES=OFF
    OPTIONS_RELEASE -DCMAKE_INSTALL_CONFIGDIR=${CURRENT_PACKAGES_DIR}/share/cppgraphqlgen -DCMAKE_INSTALL_TOOLSDIR=${CURRENT_PACKAGES_DIR}/tools/cppgraphqlgen
    OPTIONS_DEBUG -DCMAKE_INSTALL_CONFIGDIR=${CURRENT_PACKAGES_DIR}/debug/share/cppgraphqlgen -DCMAKE_INSTALL_TOOLSDIR=${CURRENT_PACKAGES_DIR}/debug/tools/cppgraphqlgen
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()

vcpkg_copy_pdbs()

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/cppgraphqlgen/copyright COPYONLY)

vcpkg_test_cmake(PACKAGE_NAME cppgraphqlgen)
