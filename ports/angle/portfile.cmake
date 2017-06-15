include(vcpkg_common_functions)

string(LENGTH "${CURRENT_BUILDTREES_DIR}" BUILDTREES_PATH_LENGTH)

if(BUILDTREES_PATH_LENGTH GREATER 27)
  message(WARNING "Angle's buildsystem uses very long paths and may fail on your system.\n"
    "We recommend moving vcpkg to a short path such as 'C:\\src\\vcpkg' or using the subst command."
  )
endif()

find_program(GIT git)
vcpkg_acquire_depot_tools(DEPOT_TOOLS)
vcpkg_find_acquire_program(PYTHON2)
vcpkg_find_acquire_program(NINJA)

set(GIT_URL "https://chromium.googlesource.com/angle/angle.git")
set(GIT_REF 8d471f907d8d4ec1d46bc9366493bd76c11c1870)

set(VCPKG_PLATFORM_TOOLSET v140)
set(MSVS_VERSION 2015)

set(GCLIENT ${DEPOT_TOOLS}/gclient.bat)


get_filename_component(PYTHON_DIRECTORY ${PYTHON2} DIRECTORY)
get_filename_component(GIT_DIRECTORY ${GIT} DIRECTORY)

set(ENV{PATH} "${GIT_DIRECTORY};${PYTHON_DIRECTORY};${PYTHON_DIRECTORY}/scripts;${DEPOT_TOOLS};$ENV{PATH};")
set(ENV{GYP_MSVS_VERSION} "${MSVS_VERSION}")
set(ENV{GYP_GENERATORS} "ninja")

if(EXISTS "${CURRENT_BUILDTREES_DIR}/src")
  message(STATUS "Cleaning previous build")
  file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/src)
  message(STATUS "Cleaning previous build done")
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO google/angle
  REF 8d471f907d8d4ec1d46bc9366493bd76c11c1870
  SHA512 b9235d2a98330bc8533c3fe871129e7235c680420eac16610eae4ca7224c5284313ab6377f30ddfb8a2da39b69f3ef0d16023fe1e7cec3fc2198f4eb4bdccb26
  HEAD_REF master
)

if (TRIPLET_SYSTEM_ARCH MATCHES "x64")
  set(APPEND_ARCH "_x64")
else ()
  set(APPEND_ARCH "")
endif()

set(DEBUG_PATH "${SOURCE_PATH}/out/Debug${APPEND_ARCH}")
set(RELEASE_PATH "${SOURCE_PATH}/out/Release${APPEND_ARCH}")

if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
  set(ENV{GYP_GENERATE_WINRT} "1")
endif()

message(STATUS "gclient config")
vcpkg_execute_required_process(
  COMMAND ${GCLIENT} config  ${GIT_URL}
  WORKING_DIRECTORY  ${SOURCE_PATH}
  LOGNAME gclient-config
)
message(STATUS "gclient config done")

message(STATUS "gclient sync")
if(NOT VCPKG_USE_HEAD_VERSION)
  vcpkg_execute_required_process(
    COMMAND ${GCLIENT} sync -r ${GIT_REF}
    WORKING_DIRECTORY  ${SOURCE_PATH}
    LOGNAME gclient-sync
  )
else()
  vcpkg_execute_required_process(
    COMMAND ${GCLIENT} sync
    WORKING_DIRECTORY  ${SOURCE_PATH}
    LOGNAME gclient-sync
  )
endif()
message(STATUS "gclient sync done")

message(STATUS "gclient runhooks")
vcpkg_execute_required_process(
  COMMAND ${GCLIENT} runhooks
  WORKING_DIRECTORY  ${SOURCE_PATH}
  LOGNAME gclient-runhooks
)
message(STATUS "gclient runhooks done")

message(STATUS "Building ${RELEASE_PATH} for Release")
vcpkg_execute_required_process(
  COMMAND ${NINJA} -C ${RELEASE_PATH}
  WORKING_DIRECTORY  ${SOURCE_PATH}
  LOGNAME build-${TARGET_TRIPLET}-rel
)

message(STATUS "Building ${DEBUG_PATH} for Debug")
vcpkg_execute_required_process(
  COMMAND ${NINJA} -C ${DEBUG_PATH}
  WORKING_DIRECTORY  ${SOURCE_PATH}
  LOGNAME build-${TARGET_TRIPLET}-dbg
)


file(GLOB DLLS
  "${RELEASE_PATH}/*.dll"
  "${RELEASE_PATH}/Release/*.dll"
  "${RELEASE_PATH}/*/Release/*.dll"
)
file(GLOB LIBS
  "${RELEASE_PATH}/*.lib"
  "${RELEASE_PATH}/Release/*.lib"
  "${RELEASE_PATH}/*/Release/*.lib"
)
file(GLOB DEBUG_DLLS
  "${DEBUG_PATH}/*.dll"
  "${DEBUG_PATH}/Debug/*.dll"
  "${DEBUG_PATH}/*/Debug/*.dll"
)
file(GLOB DEBUG_LIBS
  "${DEBUG_PATH}/*.lib"
  "${DEBUG_PATH}/Debug/*.lib"
  "${DEBUG_PATH}/*/Debug/*.lib"
)
file(GLOB HEADERS
  ${SOURCE_PATH}/include/*
)

if(DLLS)
  file(INSTALL ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
endif()
if(DEBUG_DLLS)
  file(INSTALL ${DEBUG_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
file(INSTALL ${DEBUG_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(INSTALL ${LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include )
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/angle RENAME copyright)

file(GLOB REMOVE_DLLS
  "${CURRENT_PACKAGES_DIR}/bin/d3dcompiler_47.dll"
  "${CURRENT_PACKAGES_DIR}/bin/msvcrt.dll"
  "${CURRENT_PACKAGES_DIR}/debug/bin/d3dcompiler_47.dll"
  "${CURRENT_PACKAGES_DIR}/debug/bin/msvcrt.dll"
)
if(REMOVE_DLLS)
  file(REMOVE ${REMOVE_DLLS})
endif()
vcpkg_copy_pdbs()
