include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/cppgraphqlgen
    REF v0.6
    SHA512 cc2596f5cd975377fcc9432eee11973e2ff044c244c3ac13c3f45549874c2fe0ac5c48bccb96813b48a1b7c940bb54decc194d9eb358c6ae39d1288b9ce58b01
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS -DBUILD_TESTS=OFF -DUPDATE_SAMPLES=OFF
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()

vcpkg_copy_pdbs()

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/cppgraphqlgen/copyright COPYONLY)

vcpkg_test_cmake(PACKAGE_NAME cppgraphqlgen)
