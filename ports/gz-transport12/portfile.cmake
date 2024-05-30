set(PACKAGE_NAME transport)

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}_${VERSION}
   VERSION ${VERSION}
   SHA512 8f0c02b76579679d40b16bd19796e8ac84eaace6c70889fc703d4c234970be130ca1dd18f047c0b40acd46e8f9291f199b8558329a75a33fc61c235dfcb79f4d
   OPTIONS 
   PATCHES
      uuid-osx.patch
)
