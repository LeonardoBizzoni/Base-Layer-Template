#include <iostream>

#include "../cstd/base.cpp"

int main() {
#if 1
  std::cout << "Compiler GCC:   " << COMPILER_GCC << std::endl;
  std::cout << "Compiler CL:    " << COMPILER_CL << std::endl;
  std::cout << "Compiler CLANG: " << COMPILER_CLANG << std::endl << std::endl;

  std::cout << "OS GNU/Linux:   " << OS_LINUX << std::endl;
  std::cout << "OS BSD:         " << OS_BSD << std::endl;
  std::cout << "OS MAC:         " << OS_MAC << std::endl;
  std::cout << "OS Windows:     " << OS_WINDOWS << std::endl << std::endl;

  std::cout << "Architecture x86 32bit: " << ARCH_X86 << std::endl;
  std::cout << "Architecture x64 64bit: " << ARCH_X64 << std::endl;
  std::cout << "Architecture ARM 32bit: " << ARCH_ARM << std::endl;
  std::cout << "Architecture ARM 64bit: " << ARCH_ARM64 << std::endl << std::endl;
#endif

}
