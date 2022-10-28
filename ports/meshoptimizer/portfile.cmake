vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeux/meshoptimizer
    REF 1cfd09893292e5842ba44e93709779ea28639675
    SHA512 fe767bc19bd5b718665f3b16209323eb3160841a118deabf9943a214db7860b4956642cd72274cae7ca2a3dbb5829419a78e6407340d655f37e01d53770397cb
    HEAD_REF master
)

# If we want basisu support in gltfpack we need a particular fork of basisu
# We could modify this to support using the vcpkg version of basisu
# but since this is only necessary for the gltfpack tool and not for the 
# meshopt lib it shouldn't be too nasty to just grab this repo
if ("gltfpack" IN_LIST FEATURES)
  vcpkg_from_github(
      OUT_SOURCE_PATH BASISU_PATH
      REPO zeux/basis_universal
      REF 498bba430b92f7458e5daa0fff58c2c6333b034e
      SHA512 e97df12049b0b556fc771ac5ef90ed846579f7f9f31d5b169e7df0c574fd9a96a384e0910c3a6e87ad94740a027a8abcbfcc0d21326b7cf1c469b39caf28b075
      HEAD_REF master
  )
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
  gltfpack  MESHOPT_BUILD_GLTFPACK
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      ${FEATURE_OPTIONS}
      -DMESHOPT_BUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
      -DMESHOPT_BASISU_PATH=${BASISU_PATH}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/meshoptimizer)

if ("gltfpack" IN_LIST FEATURES)
  vcpkg_copy_tools(TOOL_NAMES gltfpack AUTO_CLEAN)
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()