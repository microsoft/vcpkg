vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bungee-audio-stretch/bungee
    REF "v${VERSION}"
    SHA512 9824eb682d8b6601d9bc276b80062bc5fd910ea6a72b6798ab62ecb9750275d27ef9a58803e1f9701ae74ea203277db42840562210851c496092efec2fc1ee4d
    HEAD_REF main
    PATCHES
        cmake-use-vcpkg-deps-and-install-layout.patch
        pffft-include-path.patch
        assert-win32-compat.patch
        resample-msvc-noinline.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUNGEE_BUILD_SHARED_LIBRARY)

set(BUNGEE_INSTALL_FRAMEWORK OFF)
if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    set(BUNGEE_INSTALL_FRAMEWORK ON)
endif()

set(BUNGEE_MSVC_PDB_OPTIONS "")
if(VCPKG_TARGET_IS_WINDOWS)
    set(BUNGEE_MSVC_PDB_OPTIONS
        -DCMAKE_MSVC_DEBUG_INFORMATION_FORMAT=ProgramDatabase
        -DCMAKE_C_FLAGS_DEBUG=/Zi
        -DCMAKE_CXX_FLAGS_DEBUG=/Zi
        -DCMAKE_SHARED_LINKER_FLAGS_DEBUG=/DEBUG
        -DCMAKE_EXE_LINKER_FLAGS_DEBUG=/DEBUG
        -DCMAKE_C_FLAGS_RELEASE=/Zi
        -DCMAKE_CXX_FLAGS_RELEASE=/Zi
        -DCMAKE_SHARED_LINKER_FLAGS_RELEASE=/DEBUG
        -DCMAKE_EXE_LINKER_FLAGS_RELEASE=/DEBUG
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUNGEE_SELF_TEST=0
        -DBUNGEE_BUILD_SHARED_LIBRARY=${BUNGEE_BUILD_SHARED_LIBRARY}
        -DBUNGEE_INSTALL_FRAMEWORK=${BUNGEE_INSTALL_FRAMEWORK}
        -DBUNGEE_VERSION=${VERSION}
        -DBUNGEE_PRESET=
        ${BUNGEE_MSVC_PDB_OPTIONS}
)
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
