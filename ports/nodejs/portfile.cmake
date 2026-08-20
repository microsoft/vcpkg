# vcpkg portfile for Node.js
# Builds Node.js as both Release and Debug shared libraries for C++ embedding
set(ORG_VCPKG_LIBRARY_LINKAGE ${VCPKG_LIBRARY_LINKAGE})
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

# Find Python for the build system
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(PREPEND "${PYTHON3_PATH}")

if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_find_acquire_program(NASM)
  get_filename_component(NASM_PATH ${NASM} DIRECTORY)
  vcpkg_add_to_path(PREPEND "${NASM_PATH}")
endif()

vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}/bin")
if(EXISTS "${CURRENT_INSTALLED_DIR}/debug/bin")
  vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}/debug/bin")
endif()

message(STATUS "Current build configuration")
message(STATUS "CURRENT_INSTALLED_DIR:       ${CURRENT_INSTALLED_DIR}")
message(STATUS "CMAKE_SHARED_LIBRARY_PREFIX: ${CMAKE_SHARED_LIBRARY_PREFIX}")
message(STATUS "CMAKE_SHARED_LIBRARY_SUFFIX: ${CMAKE_SHARED_LIBRARY_SUFFIX}")
message(STATUS "CMAKE_STATIC_LIBRARY_PREFIX: ${CMAKE_STATIC_LIBRARY_PREFIX}")
message(STATUS "CMAKE_STATIC_LIBRARY_SUFFIX: ${CMAKE_STATIC_LIBRARY_SUFFIX}")
message(STATUS "PYTHON3_PATH:          ${PYTHON3_PATH}")
if(VCPKG_TARGET_IS_WINDOWS)
  message(STATUS "NASM_PATH:             ${NASM_PATH}")
endif()
message(STATUS "PATH ENV:              $ENV{PATH}")

# Download Node.js source from GitHub
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO nodejs/node
  REF "v${VERSION}"
  SHA512 dec39b2cc24d8f45bb82b38ef9c0c7452f685e301e4d957142744f155f38d96ad3cfbf96121158c549e642b328a20021d6c3df4319b35f556042eebc388ddd4b
  HEAD_REF main
  PATCHES link-windows-system-libraries.patch
)

message(STATUS "Building Node.js ${VERSION} for ${TARGET_TRIPLET}")

# Map vcpkg architecture to Node.js architecture names
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  set(NODE_ARCH "x64")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
  set(NODE_ARCH "x86")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
  set(NODE_ARCH "arm64")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
  set(NODE_ARCH "arm")
else()
  message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

# Base configure options
set(NPM_FLAG "--without-npm")
set(SHARED_FLAG "--shared")
set(LIBRARY_PREFIX "${CMAKE_SHARED_LIBRARY_PREFIX}")
if(VCPKG_TARGET_IS_WINDOWS)
  set(LIBRARY_SUFFIX "${CMAKE_STATIC_LIBRARY_SUFFIX}")
else()
  set(LIBRARY_SUFFIX "${CMAKE_SHARED_LIBRARY_SUFFIX}")
endif()

if("openssl" IN_LIST FEATURES AND NOT ORG_VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  set(EXTERNAL_OPENSSL true)
else()
  set(EXTERNAL_OPENSSL false)
endif()


function (z_copy_files)
  set(oneValueArgs FILE_SEARCH DESTINATION)
  cmake_parse_arguments(PARSE_ARGV 0 arg "" "${oneValueArgs}" "")

  if(NOT DEFINED arg_FILE_SEARCH)
    message(FATAL_ERROR "FILE_SEARCH must be specified.")
  endif()
  if(NOT DEFINED arg_DESTINATION)
    message(FATAL_ERROR "DESTINATION must be specified.")
  endif()

  message(STATUS "Copying files ${arg_FILE_SEARCH} ...")
  file(GLOB_RECURSE FILES "${arg_FILE_SEARCH}")
  foreach(FILE ${FILES})
    file(INSTALL "${FILE}" DESTINATION "${arg_DESTINATION}")
  endforeach()
endfunction()

# ============================================================================
# Function to build one configuration (Release or Debug)
# ============================================================================
function(z_build_nodejs)
  set(oneValueArgs BUILD_OUTPUT_DIR BUILD_OUTPUT_DIR_DEBUG PACKAGES_DIR PACKAGES_DIR_DEBUG)
  cmake_parse_arguments(PARSE_ARGV 0 arg "" "${oneValueArgs}" "")

  if(NOT DEFINED arg_BUILD_OUTPUT_DIR)
    message(FATAL_ERROR "BUILD_OUTPUT_DIR must be specified.")
  endif()
  if(NOT DEFINED arg_BUILD_OUTPUT_DIR_DEBUG)
    message(FATAL_ERROR "BUILD_OUTPUT_DIR_DEBUG must be specified.")
  endif()
  if(NOT DEFINED arg_PACKAGES_DIR)
    message(FATAL_ERROR "PACKAGES_DIR must be specified.")
  endif()
  if(NOT DEFINED arg_PACKAGES_DIR_DEBUG)
    message(FATAL_ERROR "PACKAGES_DIR_DEBUG must be specified.")
  endif()
  if(DEFINED arg_UNPARSED_ARGUMENTS)
    message(WARNING "z_build_nodejs was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
  endif()

  # If the external openssl is requested,
  # then we can link it against those dll and libs.
  # We assume that the external openssl is built with dynamic linkage.
  if (${EXTERNAL_OPENSSL})
    set(ENV{CL} "$ENV{CL} /DFMT_HEADER_ONLY")
    set(ENV{CXXFLAGS} "$ENV{CXXFLAGS} -DFMT_HEADER_ONLY")

    if (VCPKG_TARGET_IS_WINDOWS)
      set(OPENSSL_IS_FIPS "--openssl-is-fips")
      set(OPENSSL_LIBNAME libcrypto.lib,libssl.lib)

      # Copy the mandatory runtime dependencies so generate_node_def can load libnode.dll
      file(MAKE_DIRECTORY "${SOURCE_PATH}/out/Release")
      file(COPY "${CURRENT_INSTALLED_DIR}/bin/libcrypto-3-${NODE_ARCH}.dll" DESTINATION "${SOURCE_PATH}/out/Release")
      file(COPY "${CURRENT_INSTALLED_DIR}/bin/libssl-3-${NODE_ARCH}.dll" DESTINATION "${SOURCE_PATH}/out/Release")

      file(MAKE_DIRECTORY "${SOURCE_PATH}/out/Debug")
      file(COPY "${CURRENT_INSTALLED_DIR}/bin/libcrypto-3-${NODE_ARCH}.dll" DESTINATION "${SOURCE_PATH}/out/Debug")
      file(COPY "${CURRENT_INSTALLED_DIR}/bin/libssl-3-${NODE_ARCH}.dll" DESTINATION "${SOURCE_PATH}/out/Debug")
    else()
      set(ENV{LDFLAGS} "$ENV{LDFLAGS} -Wl,-rpath,${CURRENT_INSTALLED_DIR}/lib")
      set(OPENSSL_LIBNAME crypto,ssl)
    endif()

    set(SHARED_LIBRARY --debug-symbols
                       --shared-openssl
                       --shared-openssl-includes=${CURRENT_INSTALLED_DIR}/include
                       --shared-openssl-libpath=${CURRENT_INSTALLED_DIR}/lib
                       --shared-openssl-libname=${OPENSSL_LIBNAME}
                       ${OPENSSL_IS_FIPS}
    )
  endif()

  set(OUTPUT_DIR ${arg_BUILD_OUTPUT_DIR})
  set(OUTPUT_DIR_DEBUG ${arg_BUILD_OUTPUT_DIR_DEBUG})
  set(PACKAGES_DIR ${arg_PACKAGES_DIR})
  set(PACKAGES_DIR_DEBUG ${arg_PACKAGES_DIR_DEBUG})
  set(LIB_DEST "${PACKAGES_DIR}/lib")
  set(BIN_DEST "${PACKAGES_DIR}/bin")
  set(LIB_DEST_DEBUG "${arg_PACKAGES_DIR_DEBUG}/lib")
  set(BIN_DEST_DEBUG "${arg_PACKAGES_DIR_DEBUG}/bin")
  set(CONFIGURE_OPTIONS ${SHARED_FLAG}
                        ${NPM_FLAG}
                        ${SHARED_LIBRARY}
                        --v8-disable-temporal-support
                        --verbose
  )

  if (VCPKG_TARGET_IS_WINDOWS)
    set(BUILD_CMD "vcbuild.bat")
    list(JOIN CONFIGURE_OPTIONS " " CONFIGURE_FLAGS)
    set(ENV{config_flags} "${CONFIGURE_FLAGS} --without-node-snapshot")
    set(DEST_CPU ${NODE_ARCH})
  else()
    set(BUILD_CMD make -j${VCPKG_CONCURRENCY})
  endif()

  message(STATUS "== Building Release and Debug Configuration ==")

  # The configure command will be run by the vcbuild.bat on Windows automatically.
  # So, it is not required here.
  if (NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_execute_required_process(
      COMMAND "${PYTHON3}" configure.py
        ${CONFIGURE_OPTIONS}
        --debug
        --dest-cpu=${NODE_ARCH}
        --prefix=${CURRENT_PACKAGES_DIR}
      WORKING_DIRECTORY "${SOURCE_PATH}"
      LOGNAME configure-${TARGET_TRIPLET}
    )
  endif()

  # Build release configuration fow windows or both release and debug for other platform
  # The --debug flag in the configure.py above sets it so that it will also build
  # debug configuration after it builds the release configuration.
  # While Windows will only build 1 configuration at a time.
  vcpkg_execute_required_process(
    COMMAND ${BUILD_CMD} ${DEST_CPU}
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME build-${TARGET_TRIPLET}
  )

  if (VCPKG_TARGET_IS_WINDOWS)
    # Build debug configuration
    vcpkg_execute_required_process(
      COMMAND ${BUILD_CMD} ${DEST_CPU} debug
      WORKING_DIRECTORY "${SOURCE_PATH}"
      LOGNAME build-debug-${TARGET_TRIPLET}
    )
  endif()

  # install libnode.lib / so / dylib
  z_copy_files(FILE_SEARCH "${OUTPUT_DIR}/libnode*${LIBRARY_SUFFIX}" DESTINATION "${LIB_DEST}")
  z_copy_files(FILE_SEARCH "${OUTPUT_DIR_DEBUG}/libnode*${LIBRARY_SUFFIX}" DESTINATION "${LIB_DEST_DEBUG}")

  if (VCPKG_TARGET_IS_WINDOWS)
    # install libnode.dll and libnode.pdb
    z_copy_files(FILE_SEARCH "${OUTPUT_DIR}/libnode*${CMAKE_SHARED_LIBRARY_SUFFIX}" DESTINATION "${BIN_DEST}")
    z_copy_files(FILE_SEARCH "${OUTPUT_DIR_DEBUG}/libnode*${CMAKE_SHARED_LIBRARY_SUFFIX}" DESTINATION "${BIN_DEST_DEBUG}")
    z_copy_files(FILE_SEARCH "${OUTPUT_DIR}/libnode*.pdb" DESTINATION "${BIN_DEST}")
    z_copy_files(FILE_SEARCH "${OUTPUT_DIR_DEBUG}/libnode*.pdb" DESTINATION "${BIN_DEST_DEBUG}")
  endif()

  message(STATUS "Release and Debug configuration built successfully")
endfunction()

# ============================================================================
# Build Release and Debug configurations
# ============================================================================
z_build_nodejs(
  BUILD_OUTPUT_DIR "${SOURCE_PATH}/out/Release"
  BUILD_OUTPUT_DIR_DEBUG "${SOURCE_PATH}/out/Debug"
  PACKAGES_DIR "${CURRENT_PACKAGES_DIR}"
  PACKAGES_DIR_DEBUG "${CURRENT_PACKAGES_DIR}/debug"
)

# ============================================================================
# Install headers (shared for both configurations)
# ============================================================================
message(STATUS "Installing headers...")

file(INSTALL "${SOURCE_PATH}/src/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/node" FILES_MATCHING PATTERN "*.h")

# Install V8 headers
file(GLOB_RECURSE V8_HEADERS "${SOURCE_PATH}/deps/v8/include/*.h")
foreach(HEADER ${V8_HEADERS})
  file(RELATIVE_PATH REL_HEADER "${SOURCE_PATH}/deps/v8/include" "${HEADER}")
  get_filename_component(DIR "${REL_HEADER}" DIRECTORY)
  file(INSTALL "${HEADER}" DESTINATION "${CURRENT_PACKAGES_DIR}/include/node/${DIR}")
endforeach()

# Install libuv headers
file(INSTALL "${SOURCE_PATH}/deps/uv/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/node")

# Make sure we remove empty directories, so post-build check won't complain
file(GLOB_RECURSE ALL_DIRS LIST_DIRECTORIES true "${CURRENT_PACKAGES_DIR}/include/*")
foreach(DIR IN LISTS ALL_DIRS)
  if(IS_DIRECTORY "${DIR}")
    file(GLOB CONTENT "${DIR}/*")
    list(LENGTH CONTENT CONTENT_COUNT)
    if(CONTENT_COUNT EQUAL 0)
      file(REMOVE_RECURSE "${DIR}")
    endif()
  endif()
endforeach()

# Copy license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# ============================================================================
# Generate CMake config files
# ============================================================================
message(STATUS "Generating CMake configuration files...")

file(GLOB NODE_DLL_FILES "${CURRENT_PACKAGES_DIR}/bin/libnode*${CMAKE_SHARED_LIBRARY_SUFFIX}")
file(GLOB NODE_LIB_FILES "${CURRENT_PACKAGES_DIR}/lib/libnode*${LIBRARY_SUFFIX}")
file(GLOB NODE_DLL_DEBUG_FILES "${CURRENT_PACKAGES_DIR}/debug/bin/libnode*${CMAKE_SHARED_LIBRARY_SUFFIX}")
file(GLOB NODE_LIB_DEBUG_FILES "${CURRENT_PACKAGES_DIR}/debug/lib/libnode*${LIBRARY_SUFFIX}")

if(NODE_DLL_FILES)
  get_filename_component(NODE_RUNTIME_LIB "${NODE_DLL_FILES}" NAME)
endif()

if(NODE_LIB_FILES)
  get_filename_component(NODE_IMPORT_LIB "${NODE_LIB_FILES}" NAME)
endif()

if(NODE_DLL_DEBUG_FILES)
  get_filename_component(NODE_RUNTIME_LIB_DEBUG "${NODE_DLL_DEBUG_FILES}" NAME)
endif()

if(NODE_LIB_DEBUG_FILES)
  get_filename_component(NODE_IMPORT_LIB_DEBUG "${NODE_LIB_DEBUG_FILES}" NAME)
endif()

# Extract Node.js version
set(NODEJS_VERSION "${VERSION}")
set(PACKAGE_PREFIX_DIR ${CURRENT_PACKAGES_DIR})

# Generate CMake config files from templates
configure_file(
  "${CMAKE_CURRENT_LIST_DIR}/unofficial-nodejs-config.cmake.in"
  "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-nodejs-config.cmake"
  @ONLY
)

configure_file(
  "${CMAKE_CURRENT_LIST_DIR}/unofficial-nodejs-targets.cmake.in"
  "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-nodejs-targets.cmake"
  @ONLY
)

# Usage file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

message(STATUS "Node.js build complete - Release and Debug configurations installed")
