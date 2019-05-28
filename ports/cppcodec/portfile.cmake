include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tplgy/cppcodec
    REF v0.2
    SHA512 50c9c81cdb12560c87e513e1fd22c1ad24ea37b7d20a0e3044d43fb887f4c6494c69468e4d0811cd2fc1ae8fdb01b01cfb9f3cfdd8611d4bb0221cbd38cbead3
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

# Replace Cmake file with custom one that doesn't build any binaries
file(WRITE "${SOURCE_PATH}/CMakeLists.txt" [=[
cmake_minimum_required(VERSION 2.8.5)
project(cppcodec CXX)
set(PROJECT_VERSION 0.2)

include(GNUInstallDirs)
include(CTest)

# These flags are for binaries built by this particular CMake project (test_cppcodec, base64enc, etc.).
# In your own project that uses cppcodec, you might want to specify a different standard or error level.

# Request C++11, or let the user specify the standard on via -D command line option.
if (NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 17)
endif()
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if (MSVC)
  # MSVC will respect CMAKE_CXX_STANDARD for CMake >= 3.10 and MSVC >= 19.0.24215
  # (VS 2017 15.3). Older versions will use the compiler default, which should be
  # fine for anything except ancient MSVC versions.
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W4")
else()
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -pedantic")

  # CMake versions before 3.1 do not understand CMAKE_CXX_STANDARD.
  # Remove this block once CMake >=3.1 has fixated in the ecosystem.
  if(${CMAKE_VERSION} VERSION_LESS 3.1)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++${CMAKE_CXX_STANDARD}")
  endif()
endif()

set(PUBLIC_HEADERS
    # base32
    cppcodec/base32_crockford.hpp
    cppcodec/base32_default_crockford.hpp
    cppcodec/base32_default_hex.hpp
    cppcodec/base32_default_rfc4648.hpp
    cppcodec/base32_hex.hpp
    cppcodec/base32_rfc4648.hpp
    # base64
    cppcodec/base64_default_rfc4648.hpp
    cppcodec/base64_default_url.hpp
    cppcodec/base64_default_url_unpadded.hpp
    cppcodec/base64_rfc4648.hpp
    cppcodec/base64_url.hpp
    cppcodec/base64_url_unpadded.hpp
    # hex
    cppcodec/hex_default_lower.hpp
    cppcodec/hex_default_upper.hpp
    cppcodec/hex_lower.hpp
    cppcodec/hex_upper.hpp
    # other stuff
    cppcodec/parse_error.hpp
    cppcodec/data/access.hpp
    cppcodec/data/raw_result_buffer.hpp
    cppcodec/detail/base32.hpp
    cppcodec/detail/base64.hpp
    cppcodec/detail/codec.hpp
    cppcodec/detail/config.hpp
    cppcodec/detail/hex.hpp
    cppcodec/detail/stream_codec.hpp)

add_library(cppcodec OBJECT ${PUBLIC_HEADERS}) # unnecessary for building, but makes headers show up in IDEs
set_target_properties(cppcodec PROPERTIES LINKER_LANGUAGE CXX)

foreach(h ${PUBLIC_HEADERS})
    get_filename_component(FINAL_PATH ${h} PATH) # use DIRECTORY instead of PATH once requiring CMake 3.0
    install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/${h} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${FINAL_PATH} COMPONENT "headers")
endforeach()
]=])

# Remove folders with binaries
file(REMOVE_RECURSE ${SOURCE_PATH}/example;${SOURCE_PATH}/test;${SOURCE_PATH}/tool)

# Patch `stream_codec.hpp`
set(STREAM_CODEC_SOURCE_PATH ${SOURCE_PATH}/cppcodec/detail/stream_codec.hpp)
file(READ ${STREAM_CODEC_SOURCE_PATH} STREAM_CODEC_SOURCE)
string(REPLACE "static_cast<intmax_t>(std::numeric_limits<T>::max())" "static_cast<intmax_t>((std::numeric_limits<T>::max)())" STREAM_CODEC_SOURCE "${STREAM_CODEC_SOURCE}")
string(REPLACE "static_cast<intmax_t>(std::numeric_limits<T>::min())" "static_cast<intmax_t>((std::numeric_limits<T>::min)())" STREAM_CODEC_SOURCE "${STREAM_CODEC_SOURCE}")
file(WRITE ${STREAM_CODEC_SOURCE_PATH} "${STREAM_CODEC_SOURCE}")

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cppcodec RENAME copyright)
