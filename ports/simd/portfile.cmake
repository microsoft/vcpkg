vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ermig1979/Simd
    REF e61df320747449322767e67534bd7bb6a9a6d2c8 # v5.1.119
    SHA512 9dfce424af8600aaa2c0eac8bbb8f20b12cbd086d495c7e9e1ce2a45ae60242ee893608fc41c88ff6caa960821188e4cffd586b416ab891ee86d6e28aad54726
    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS)
  #architecture detection
  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
  	set(SIMD_PLATFORM "Win32")
  elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  	set(SIMD_PLATFORM "x64")
  else()
  	message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
  endif()
  
  if(VCPKG_PLATFORM_TOOLSET MATCHES "v140")
    set(SOLUTION_TYPE vs2015)
  elseif(VCPKG_PLATFORM_TOOLSET MATCHES "v141")
    set(SOLUTION_TYPE vs2017)
  elseif(VCPKG_PLATFORM_TOOLSET MATCHES "v142")
    set(SOLUTION_TYPE vs2019)
  else()
    set(SOLUTION_TYPE vs2022)
  endif()
  
  vcpkg_install_msbuild(
  	SOURCE_PATH ${SOURCE_PATH}
  	PROJECT_SUBPATH "/prj/${SOLUTION_TYPE}/Simd.sln"
  	PLATFORM ${SIMD_PLATFORM}
  	TARGET Simd
  	RELEASE_CONFIGURATION "Release"
  	DEBUG_CONFIGURATION "Debug"
  )
  
  file(COPY "${SOURCE_PATH}/src/Simd/SimdLib.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
else()
  message(FATAL_ERROR "Other Targets then Windows are not jet supported")
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)