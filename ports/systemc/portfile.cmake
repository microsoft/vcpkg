include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/systemc-2.3.3)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.accellera.org/images/downloads/standards/systemc/systemc-2.3.3.zip"
    FILENAME "systemc-2.3.3.zip"
    SHA512 f4df172addf816a1928d411dcab42c1679dc4c9d772f406c10d798a2c174d89cdac7a83947fa8beea1e3aff93da522d2d2daf61a4841ec456af7b7446c5c4a14
)
vcpkg_extract_source_archive(${ARCHIVE})

set(VCPKG_LIBRARY_LINKAGE static)

vcpkg_apply_patches(
  SOURCE_PATH ${SOURCE_PATH}
  PATCHES
  ${CMAKE_CURRENT_LIST_DIR}/install.patch
  ${CMAKE_CURRENT_LIST_DIR}/tlm_correct_dependency.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DCMAKE_CXX_STANDARD=17
        -DDISABLE_COPYRIGHT_MESSAGE=ON
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/NOTICE DESTINATION ${CURRENT_PACKAGES_DIR}/share/systemc RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(READ ${CURRENT_PACKAGES_DIR}/debug/share/SystemCLanguage/SystemCLanguageTargets-debug.cmake _contents)
string(REPLACE "lib/" "debug/lib/" _contents "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/SystemCLanguage/SystemCLanguageTargets-debug.cmake "${_contents}")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/sysc/packages/qt/time)

# Post-build test for cmake libraries
vcpkg_test_cmake(PACKAGE_NAME SystemCLanguage)
vcpkg_test_cmake(PACKAGE_NAME SystemCTLM)
