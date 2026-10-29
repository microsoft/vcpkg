cmake_minimum_required (VERSION 3.9)
project (sparsepp)

set(HEADERS
        sparsepp/spp.h
        sparsepp/spp_config.h
        sparsepp/spp_dlalloc.h
        sparsepp/spp_memory.h
        sparsepp/spp_smartptr.h
        sparsepp/spp_stdint.h
        sparsepp/spp_timer.h
        sparsepp/spp_traits.h
        sparsepp/spp_utils.h
        )

if(NOT DISABLE_INSTALL_HEADERS)
    install(FILES ${HEADERS} DESTINATION include/sparsepp)
endif()
