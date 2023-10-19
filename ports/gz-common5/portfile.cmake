set(PACKAGE_NAME common)

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}_${VERSION}
   VERSION ${VERSION}
   SHA512 40db4747db743005d7c43ca25cfe93cf68ee19201abcb165e72de37708b92fd88553b11520c420db33b37f4cab7e01e4d79c91c5dc0485146b7156284b8baaee
   OPTIONS 
      -DUSE_EXTERNAL_TINYXML2=ON
   PATCHES
      fix_dependencies.patch
      remove_tests.patch
      gz_remotery_vis.patch
)
