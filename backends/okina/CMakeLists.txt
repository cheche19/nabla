info("${VT100_BOLD}${VT100_FG_GREEN}#######################${VT100_RESET}")
info("${VT100_BOLD}${VT100_FG_GREEN}# NABLA BACKEND OKINA #${VT100_RESET}")
info("${VT100_BOLD}${VT100_FG_GREEN}#######################${VT100_RESET}")
info("${VT100_BOLD}${VT100_FG_CYAN}NABLA${VT100_RESET} adding ${VT100_FG_YELLOW}BACKEND${VT100_RESET}: ${VT100_BOLD}${VT100_FG_YELLOW}OKINA${VT100_RESET}")

set(BACKEND_OKINA_C okina.c header.c)

add_library(NablaOkina ${BACKEND_OKINA_C})
add_dependencies(NablaOkina Nabla)

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/dump)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/call/para)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/call/simd)

target_link_libraries(NablaOkina NablaOkinaCallSimd NablaOkinaCallPara NablaOkinaDump)
#install(TARGETS NablaOkina DESTINATION lib)
