
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  set(nodejs_arch "x64")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
  set(nodejs_arch "ia32")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
  set(nodejs_arch "arm64")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
  set(nodejs_arch "arm")
else()
  message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

# Copy files to the build tree
file(COPY "${NODE_API_INC}" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
if(NODE_API_LIB)
  file(COPY "${NODE_API_LIB}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
  file(COPY "${NODE_API_LIB}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()
if(NODE_API_SRC)
  file(COPY "${NODE_API_SRC}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endif()

# Handle copyright
file(INSTALL "${NODEJS_DIR}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Copy ./unofficial-node-api-config.cmake to ${CURRENT_PACKAGES_DIR}/share/node-api
file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-node-api-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")