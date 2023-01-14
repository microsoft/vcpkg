set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

if(NOT TARGET_TRIPLET STREQUAL _HOST_TRIPLET)
    message(FATAL_ERROR "vcpkg-gn is a host-only port; please mark it as a host port in your dependencies.")
endif()

set(BASE_URL "https://chrome-infra-packages.appspot.com/dl/gn/gn")
set(PLATFORM "")
set(ID "")
set(HASH "")

if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(PLATFORM "windows-amd64")
        set(ID "UXzb_By8w0nZJ4HNiOo0-ylLKn97JMEGeFgu7lh-5bYC")
        set(HASH "4508eee7a8d594d31d34a9810371ba13f0b233642ed89b0185ef209165af1c1b2df49d4b5020e01f333a0724b66bcae80133db8f6256d37295b02927743eaddf")
    else()
        message(FATAL_ERROR "Only x64 is supported on Windows")
    endif()
elseif(VCPKG_TARGET_IS_OSX)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(PLATFORM "mac-amd64")
        set(ID "Al2dYNoD4IBgOnjJSohdXIZMhZJIqHeyaE2AiqWYfIYC")
        set(HASH "98b0f6c99ab5e9f6aac448e19aa22d6f2a4924cff51493ce905be7329e1575575c5b9be96e86b07eb0be7215718bf6384bcee01233c8ef0d5554bfa3f51fc811")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(PLATFORM "mac-arm64")
        set(ID "WVStyq9u1pq0xScIl-o4nOlNBYTHCQQCV0KPhgRAAhEC")
        set(HASH "ec7a46574d6dc4177e02ac0e558da59dfaa503bf2263c904b09145bc5cbee759c91f0b55b4bc9f372953af78eb3ac6ad98e0fc1b1cf419689a1f7615c786311d")
    else()
        message(FATAL_ERROR "Only x64 and arm64 are supported on osx")
    endif()
elseif(VCPKG_TARGET_IS_LINUX)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(PLATFORM "linux-amd64")
        set(ID "bMLaJoqEAsCsT5M_sG6KxlaiRQ5aS2RVhrC2qLPilE8C")
        set(HASH "fd073139b4ca816dd9f742232d565017237589ec62d02dcb2e54a1d22350450e61b11cc8aa9acd645565f7aac62f9d0bf64ca30f8e6c07f547c746cea3998064")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(PLATFORM "linux-arm64")
        set(ID "A_VzbiVBrgO0cxX_Iyt8FomIH-WU8YAG2LW8FAhSaOgC")
        set(HASH "71da448fd496f803d241ef3656a0c69889a7084624f7f6f92c5326b6e7c0a67b386c69f5cff1a07402b5aa57f5d754a23e09191bbecae8d443ad9896198e36a7")
    else()
        message(FATAL_ERROR "Only x64 and arm64 are supported on linux")
    endif()
else()
    message(FATAL_ERROR "Target not yet supported by '${PORT}'")
endif()

set(URL "${BASE_URL}/${PLATFORM}/+/${ID}")
message(STATUS "URL: '${URL}'")

vcpkg_download_distfile(ARCHIVE_PATH
  URLS "${URL}"
  SHA512 "${HASH}"
  FILENAME "gn-${PLATFORM}-${ID}.zip"
  #ALWAYS_REDOWNLOAD
  #SKIP_SHA512
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
message(STATUS "ARCHIVE_PATH: '${ARCHIVE_PATH}'")

vcpkg_execute_in_download_mode(
    COMMAND ${CMAKE_COMMAND} -E tar xzf "${ARCHIVE_PATH}" 
    WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
)
file(GLOB_RECURSE folders "${CURRENT_PACKAGES_DIR}/tools/${PORT}/*" LIST_DIRECTORIES true)
message(STATUS "Files and Folders: '${folders}'")

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg_gn_configure.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg_gn_install.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
