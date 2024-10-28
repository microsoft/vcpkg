vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeux/meshoptimizer
    REF v${VERSION}
    SHA512 801cdc911da6ece7afe2ae4f5d002f27e8a0b5072ec4332968183941671024b3cda2a45266c0899cc9fb134d3b931d70b3bd9629dc7765f77e102146b2f6bfd0
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
      REF 91ca86492bc046bf1d096067a1adcd2309e13dd2
      SHA512 fe80533db60b40cdc72a64f766c2447ce5c923d84467a926c2e8af4ec42e278d9fa9823b41b3fc7d9b740dd2d41d2f606f0f9990f94d2398f253bc86350a4287
      HEAD_REF gltfpack
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