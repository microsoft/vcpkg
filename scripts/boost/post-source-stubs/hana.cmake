if("large-struct-macros" IN_LIST FEATURES)
    if(VCPKG_TARGET_IS_WINDOWS)
        set(BOOST_HANA_MAX_NUMBER_OF_MEMBERS 124)
    else()
        set(BOOST_HANA_MAX_NUMBER_OF_MEMBERS 200)
    endif()

    math(EXPR BOOST_HANA_GENERATOR_LIMIT "${BOOST_HANA_MAX_NUMBER_OF_MEMBERS} + 1")
    vcpkg_find_acquire_program(RUBY)
    vcpkg_execute_required_process(
        COMMAND "${RUBY}" -rerb -e "ENV['MAX_NUMBER_OF_MEMBERS'] = ARGV[0]; print ERB.new(File.read(ARGV[1])).result" "${BOOST_HANA_GENERATOR_LIMIT}" "${SOURCE_PATH}/include/boost/hana/detail/struct_macros.hpp.erb"
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "boost-hana-generate-struct-macros"
        OUTPUT_VARIABLE _boost_hana_struct_macros
    )
    file(WRITE "${SOURCE_PATH}/include/boost/hana/detail/struct_macros.hpp" "${_boost_hana_struct_macros}")
    message(STATUS "boost-hana: generated struct_macros.hpp for up to ${BOOST_HANA_MAX_NUMBER_OF_MEMBERS} members")
endif()
