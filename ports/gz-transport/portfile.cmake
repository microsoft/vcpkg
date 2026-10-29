string(REGEX MATCH "^[0-9]+" VERSION_MAJOR "${VERSION}")
string(REGEX REPLACE "^gz-" "" PACKAGE_NAME "${PORT}")

vcpkg_find_acquire_program(PYTHON3)

ignition_modular_library(
   NAME "${PACKAGE_NAME}"
   REF "${PORT}${VERSION_MAJOR}_${VERSION}"
   VERSION "${VERSION}"
   SHA512 816583b3b632c3574b8720f9ffa6576bde780c4bd433d25101e05bf1c9bc8e6d458eded6c7f0cf457e4985057757eebd153bf77f7b6b1108fbe308d5289cb0b8
   OPTIONS 
      "-DPython3_EXECUTABLE=${PYTHON3}"
      -DSKIP_PYBIND11=ON
   PATCHES
      uuid-osx.patch
)
