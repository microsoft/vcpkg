#header-only library
set(USE_UPSTREAM OFF)
if("upstream" IN_LIST FEATURES)
    set(USE_UPSTREAM ON)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO crossbario/autobahn-cpp
    REF 84972fc81181bde635329bf0474e3874cc5c9091 # v20.8.1
    SHA512 fcd094907826e035188d19efc80f3caa6c90d7d7bd2c5b6796aea9de3a02052bd049329cbe5cb242bba535e70c127842c66d34956e715b4f6f37ffc54c39c483
    HEAD_REF master
)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/autobahn)

# Copy the header files
file(COPY "${SOURCE_PATH}/autobahn" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN "*.hpp")
file(COPY "${SOURCE_PATH}/autobahn" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN "*.ipp")

set(PACKAGE_INSTALL_INCLUDE_DIR "\${CMAKE_CURRENT_LIST_DIR}/../../include")
set(PACKAGE_INIT "
macro(set_and_check)
  set(\${ARGV})
endmacro()
")

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/autobahn/copyright COPYONLY)
