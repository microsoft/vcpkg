if(COMMAND vcpkg_find_acquire_program)
    set(VCPKG_HOST_IS_WINDOWS TRUE)
    vcpkg_find_acquire_program(CLANG)
    cmake_path(GET CLANG PARENT_PATH LLVM_ROOT)
    cmake_path(GET LLVM_ROOT PARENT_PATH LLVM_ROOT)
    set(ENV{LLVMInstallDir} "${LLVM_ROOT}")
    set(ENV{LLVMToolsVersion} "17.0.6")
    #set(PATH_BACKUP "$ENV{PATH}")
    #set(ENV{PATH} "${LLVM_ROOT}/bin;$ENV{PATH}")
    file(REMOVE "${LLVM_ROOT}/bin/link.exe")
    #if(NOT EXISTS "${LLVM_ROOT}/bin/link.exe")
    #    file(CREATE_LINK "${LLVM_ROOT}/bin/lld-link.exe" "${LLVM_ROOT}/bin/link.exe" COPY_ON_ERROR)
    #endif()

    #To build stuff without needing -m<feature> flags and be more like MSVC
    if(NOT EXISTS "${LLVM_ROOT}/vcpkg_replacement")
      set(files
        x86intrin.h
        keylockerintrin.h
        immintrin.h
        bmiintrin.h
      )
      foreach(header IN LISTS files)
          vcpkg_replace_string("${LLVM_ROOT}/lib/clang/17/include/${header}" "!(defined(_MSC_VER) || defined(__SCE__))" "defined(_MSC_VER) || !defined(__SCE__)")
      endforeach()
      file(WRITE "${LLVM_ROOT}/vcpkg_replacement")
    endif()
endif()

#set(VCPKG_CMAKE_CONFIGURE_OPTIONS --trace-expand)