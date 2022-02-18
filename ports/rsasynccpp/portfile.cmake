vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH  SOURCE_PATH
    REPO renestein/Rstein.AsyncCpp
    REF 0.0.7
    SHA512   b4cc1c68b6fc7bb8b418457ba18b834769abec07e44305955214f8918cc57f85c4258a0521ea55388fab3ec9724488e506d2b114c765b804991c38bf33133c55
    HEAD_REF master
)

if("lib-cl-win-legacy-await" IN_LIST FEATURES)
  if (VCPKG_CRT_LINKAGE MATCHES "static")
    set(RELEASE_CONFIGURATION  "ReleaseMT_VSAWAIT")
    set(DEBUG_CONFIGURATION    "DebugMT_VSAWAIT")
  else()
    set(RELEASE_CONFIGURATION  "Release_VSAWAIT")
    set(DEBUG_CONFIGURATION    "Debug_VSAWAIT")
  endif()
else()
  if (VCPKG_CRT_LINKAGE MATCHES "static")
    set(RELEASE_CONFIGURATION "ReleaseMT")
    set(DEBUG_CONFIGURATION   "DebugMT")
  else()
    set(RELEASE_CONFIGURATION  "Release")
    set(DEBUG_CONFIGURATION    "Debug")
  endif()
endif()

if (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    set(MSBUILD_PLATFORM "x86")
else ()
    set(MSBUILD_PLATFORM ${TRIPLET_SYSTEM_ARCH})
endif()


vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH RStein.AsyncCppLib.sln
    LICENSE_SUBPATH LICENSE
    PLATFORM ${MSBUILD_PLATFORM}
    DEBUG_CONFIGURATION ${DEBUG_CONFIGURATION}
    RELEASE_CONFIGURATION ${RELEASE_CONFIGURATION}
)

file(COPY "${SOURCE_PATH}/RStein.AsyncCpp/"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/asynccpp"
    FILES_MATCHING PATTERN "*.h")
