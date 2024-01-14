include(Platform/Windows-Clang)
__windows_compiler_clang(CUDA)

set(CMAKE_LIBRARY_PATH_FLAG "-LIBPATH:")
set(CMAKE_LINK_LIBRARY_FLAG "")
set(CMAKE_COMPILER_SUPPORTS_PDBTYPE 1)

#foreach(dir ${CMAKE_CUDA_HOST_IMPLICIT_LINK_DIRECTORIES})
#  string(APPEND __IMPLICIT_LINKS " ${CMAKE_LIBRARY_PATH_FLAG}\"${dir}\"")
#endforeach()

#set(CMAKE_MSVC_RUNTIME_LIBRARY_DEFAULT "")

set(CMAKE_CUDA_STANDARD_LIBRARIES "kernel32.lib user32.lib gdi32.lib winspool.lib shell32.lib ole32.lib oleaut32.lib uuid.lib comdlg32.lib advapi32.lib oldnames.lib")

set(_CMAKE_CUDA_WHOLE_FLAG "-c")
set(_CMAKE_CUDA_RDC_FLAG "-fgpu-rdc")
set(_CMAKE_CUDA_PTX_FLAG "--cuda-device-only -S")
#set(CMAKE_DEPFILE_FLAGS_CUDA "-MD -MT <DEP_TARGET> -MF <DEP_FILE>")
set(CMAKE_CUDA_COMPILER_HAS_DEVICE_LINK_PHASE TRUE)
set(_CMAKE_CUDA_IPO_SUPPORTED_BY_CMAKE NO)
set(_CMAKE_CUDA_IPO_MAY_BE_SUPPORTED_BY_COMPILER NO)

set(CMAKE_CUDA_RUNTIME_LIBRARY_DEFAULT "STATIC")
set(CMAKE_CUDA_RUNTIME_LIBRARY_LINK_OPTIONS_STATIC "cudadevrt.lib;cudart_static.lib")
set(CMAKE_CUDA_RUNTIME_LIBRARY_LINK_OPTIONS_SHARED "cudadevrt.lib;cudart.lib")

set(CMAKE_CUDA_RUNTIME_LIBRARY "None") # Since the added libs are somehow not controlled by CUDA_RUNTIME_LIBRARY above

#${CMAKE_LIBRARY_PATH_FLAG}${CMAKE_CUDA_COMPILER_TOOLKIT_LIBRARY_ROOT}/lib

set(CMAKE_CUDA_STANDARD_LIBRARIES "cudadevrt.lib cudart_static.lib kernel32.lib user32.lib gdi32.lib winspool.lib shell32.lib ole32.lib oleaut32.lib uuid.lib comdlg32.lib advapi32.lib oldnames.lib")

set(_CMAKE_VS_LINK_DLL "<CMAKE_COMMAND> -E vs_link_dll --intdir=<OBJECT_DIR> --rc=<CMAKE_RC_COMPILER> --mt=<CMAKE_MT> --manifests <MANIFESTS> -- ")
set(_CMAKE_VS_LINK_EXE "<CMAKE_COMMAND> -E vs_link_exe --intdir=<OBJECT_DIR> --rc=<CMAKE_RC_COMPILER> --mt=<CMAKE_MT> --manifests <MANIFESTS> -- ")

#set(CMAKE_CUDA_LINK_EXECUTABLE "<CMAKE_CXX_COMPILER> -fuse-ld=lld-link -nostartfiles -nostdlib <FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> -Xlinker /implib:<TARGET_IMPLIB> -Xlinker /pdb:<TARGET_PDB> -Xlinker /version:<TARGET_VERSION_MAJOR>.<TARGET_VERSION_MINOR> <LINK_LIBRARIES>${__IMPLICIT_LINKS} /LIBPATH:$ENV{CUDA_PATH}/lib")
#set(CMAKE_CUDA_CREATE_SHARED_LIBRARY "<CMAKE_CXX_COMPILER> -fuse-ld=lld-link -nostartfiles -nostdlib <CMAKE_SHARED_LIBRARY_CUDA_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_CUDA_FLAGS> -o <TARGET> -Xlinker /implib:<TARGET_IMPLIB> -Xlinker /pdb:<TARGET_PDB> -Xlinker /dll -Xlinker /version:<TARGET_VERSION_MAJOR>.<TARGET_VERSION_MINOR> <OBJECTS> <LINK_LIBRARIES>${__IMPLICIT_LINKS} /LIBPATH:$ENV{CUDA_PATH}/lib")
#set(CMAKE_CUDA_CREATE_SHARED_MODULE ${CMAKE_CUDA_CREATE_SHARED_LIBRARY})

set(lang CUDA)
set(CMAKE_CUDA_HOST_LINK_LAUNCHER "${CMAKE_LINKER}")
#set(CMAKE_${lang}_CREATE_SHARED_LIBRARY
#    "${_CMAKE_VS_LINK_DLL}<CMAKE_CXX_COMPILER> -fuse-ld=lld-link -Xclang -nostartfiles -Xclang -nostdlib <OBJECTS> /link ${CMAKE_START_TEMP_FILE} /out:<TARGET> /implib:<TARGET_IMPLIB> /pdb:<TARGET_PDB> /dll /version:<TARGET_VERSION_MAJOR>.<TARGET_VERSION_MINOR>${_PLATFORM_LINK_FLAGS} <CMAKE_${lang}_LINK_FLAGS> <LINK_FLAGS> <LINK_LIBRARIES>${CMAKE_END_TEMP_FILE}")
set(CMAKE_${lang}_USE_RESPONSE_FILE_FOR_OBJECTS 1)
#set(CMAKE_${lang}_LINK_EXECUTABLE
#    "${_CMAKE_VS_LINK_EXE}<CMAKE_CXX_COMPILER> -fuse-ld=lld-link -Xclang -nostartfiles -Xclang -nostdlib <OBJECTS> /link ${CMAKE_START_TEMP_FILE} /out:<TARGET> /implib:<TARGET_IMPLIB> /pdb:<TARGET_PDB> /version:<TARGET_VERSION_MAJOR>.<TARGET_VERSION_MINOR>${_PLATFORM_LINK_FLAGS} <CMAKE_${lang}_LINK_FLAGS> <LINK_FLAGS> <LINK_LIBRARIES>${CMAKE_END_TEMP_FILE}")
set(CMAKE_${lang}_COMPILE_OPTIONS_MSVC_RUNTIME_LIBRARY_MultiThreaded         -MT)
set(CMAKE_${lang}_COMPILE_OPTIONS_MSVC_RUNTIME_LIBRARY_MultiThreadedDLL      -MD)
set(CMAKE_${lang}_COMPILE_OPTIONS_MSVC_RUNTIME_LIBRARY_MultiThreadedDebug    -MTd)
set(CMAKE_${lang}_COMPILE_OPTIONS_MSVC_RUNTIME_LIBRARY_MultiThreadedDebugDLL -MDd)
unset(lang)
#set(CMAKE_CUDA_COMPILE_OBJECT <CMAKE_CUDA_COMPILER>  <DEFINES> <INCLUDES> <FLAGS> -x cuda <CUDA_COMPILE_MODE> <SOURCE> -o <OBJECT> )
set(CMAKE_CUDA_COMPILE_OBJECT
  "<CMAKE_CUDA_COMPILER> ${_CMAKE_CUDA_EXTRA_FLAGS} -Xcuda-ptxas -c <DEFINES> <INCLUDES> <FLAGS> --cuda-path=${CMAKE_CUDA_COMPILER_TOOLKIT_LIBRARY_ROOT} ${_CMAKE_COMPILE_AS_CUDA_FLAG} <CUDA_COMPILE_MODE> <SOURCE> -o <OBJECT> -object-file-name=<TARGET_COMPILE_PDB>")
set(CMAKE_CUDA_STANDARD_LIBRARIES_INIT "${CMAKE_C_STANDARD_LIBRARIES_INIT}")

#-Xcuda-ptxas --register-usage-level -Xcuda-ptxas 10 -Xcuda-ptxas --device-function-maxrregcount -Xcuda-ptxas 255 -Xcuda-ptxas --maxrregcount -Xcuda-ptxas 255 -Xcuda-ptxas -allow-expensive-optimizations -Xcuda-ptxas true

set(CMAKE_INCLUDE_SYSTEM_FLAG_CUDA "-isystem ")
set(CMAKE_DEPFILE_FLAGS_CUDA "")
#set(CMAKE_DEPFILE_FLAGS_CUDA "-MD -MT <DEP_TARGET> -MF <DEP_FILE>")
