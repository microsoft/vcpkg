if(ANDROID)
    include(CheckFunctionExists)
    check_function_exists("glob" HAVE_GLOB_H)
endif()
