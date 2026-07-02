if("feature-a" IN_LIST FEATURES)
  if (NOT VCPKG_TARGET_IS_WINDOWS)
    message(FATAL_ERROR "This is a Windows-only feature")
  endif()
endif()

set(VCPKG_BUILD_TYPE release) # header-only library

file(INSTALL 
  DESTINATION "${CURRENT_PACKAGES_DIR}/include/vcpkg-ci-eval"
  FILES "${CMAKE_CURRENT_LIST_DIR}/config.h"
)

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "MIT\n")
