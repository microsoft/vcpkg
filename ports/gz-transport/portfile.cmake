string(REGEX MATCH "^[0-9]+" VERSION_MAJOR "${VERSION}")
string(REGEX REPLACE "^gz-" "" PACKAGE_NAME "${PORT}")

vcpkg_find_acquire_program(PYTHON3)

ignition_modular_library(
   NAME "${PACKAGE_NAME}"
   REF "${PORT}${VERSION_MAJOR}_${VERSION}"
   VERSION "${VERSION}"
   SHA512 c006bc4eec27c863c24149cf5857d392cec8aa2be877fcf3f9b094d5fcab7eb656e61c84950507693c81eec1e3dc64edb23dc799a54125169e780f7b8fe10980
   OPTIONS 
      "-DPython3_EXECUTABLE=${PYTHON3}"
      -DSKIP_PYBIND11=ON
   PATCHES
      uuid-osx.patch
)
