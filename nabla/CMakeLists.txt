info("${VT100_BOLD}${VT100_FG_CYAN}NABLA${VT100_RESET} gathering ${VT100_FG_YELLOW}NABLA${VT100_RESET}")

bison_target(nParser nabla.y ${CMAKE_CURRENT_BINARY_DIR}/nabla.tab.c COMPILE_FLAGS "--report=all")#--warnings=all,error --graph 
flex_target(nScanner nabla.l ${CMAKE_CURRENT_BINARY_DIR}/nabla.lex.c COMPILE_FLAGS "")
add_flex_bison_dependency(nScanner nParser)

configure_file(nabla.S ${CMAKE_CURRENT_BINARY_DIR}/nabla.asm.S)
add_executable(nabla nabla.c ${CMAKE_CURRENT_BINARY_DIR}/nabla.asm.S)
add_library(Nabla ${BISON_nParser_OUTPUTS} ${FLEX_nScanner_OUTPUTS})

##################
# Link libraries #
##################
target_link_libraries(nabla Nabla NablaMiddlend NablaFrontend NablaTools
                      NablaArcane NablaCuda NablaOkina NablaLambda
                      NablaRaja NablaKokkos NablaLegion
                      NablaLibCall NablaLibHook NablaLibDump NablaAleph)

###########
# INSTALL #
###########
install(TARGETS nabla DESTINATION bin)
