vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ermig1979/Simd
    REF 96dfde3b243687d796426719cf354b47fd4cd727 # v5.2.120
    SHA512 4f506309aad77994967ea804b6891892e203531ce37afc0044a88b2a33c81fdaef2f514deb0421034489d08c4bd1d1c6155adfc65325d0a55063dddb113a3ea8
    HEAD_REF master
    PATCHES
        fix-CMakeLists-install.patch
)

if(VCPKG_TARGET_IS_WINDOWS AND (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64"))
  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
  	set(SIMD_PLATFORM "Win32")
  elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  	set(SIMD_PLATFORM "x64")
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
   
  if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${SOURCE_PATH}/src/Simd/SimdConfig.h"
	    "//#define SIMD_STATIC"
	    "#define SIMD_STATIC")
    vcpkg_replace_string("${SOURCE_PATH}/prj/${SOLUTION_TYPE}/Simd.vcxproj"
	     "<ConfigurationType>DynamicLibrary</ConfigurationType>"
		 "<ConfigurationType>StaticLibrary</ConfigurationType>")
    if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
	  file(GLOB_RECURSE PROJ_FILES "${SOURCE_PATH}/prj/${SOLUTION_TYPE}/*.vcxproj")
	  foreach(PROJ_FILE ${PROJ_FILES})
        vcpkg_replace_string(${PROJ_FILE}
	      "    </ClCompile>"
	      "      <RuntimeLibrary Condition=\"'$(Configuration)'=='Debug'\">MultiThreadedDebugDLL</RuntimeLibrary>\n      <RuntimeLibrary Condition=\"'$(Configuration)'=='Release'\">MultiThreadedDLL</RuntimeLibrary>\n    </ClCompile>")
	  endforeach()
    endif()
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
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
  if(VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    message(FATAL_ERROR "Arm64 building with MSVC is currently not supported.")
  else()
    vcpkg_configure_cmake(
      SOURCE_PATH "${SOURCE_PATH}/prj/cmake"
	  OPTIONS
	    -DSIMD_TARGET="aarch64"
    )
    vcpkg_cmake_install()
    vcpkg_cmake_config_fixup()
    vcpkg_copy_pdbs()
  
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
  endif()
else()
  vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}/prj/cmake"
  )
  vcpkg_cmake_install()
  vcpkg_cmake_config_fixup()
  vcpkg_copy_pdbs()
  
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
