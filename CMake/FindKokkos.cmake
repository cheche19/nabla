include(${NABLA_SOURCE_DIR}/CMake/CMakeTPL.txt)


find_path(KOKKOS_ROOT_PATH Makefile.kokkos ${KOKKOS_ROOT})
info("${VT100_FG_MAGENTA}KOKKOS${VT100_RESET} set to ${VT100_BOLD}${KOKKOS_ROOT_PATH}${VT100_RESET}")

if(KOKKOS_ROOT_PATH)
  set(KOKKOS_FOUND "YES")
endif(KOKKOS_ROOT_PATH)