#include <stdio.h>

#include <base/base_inc.h>
#include <OS/os_inc.h>

#include <base/base_inc.c>
#include <OS/os_inc.c>

fn void start(CmdLine *cli) {
#if 1
  Info("Compiler GCC:   %d", COMPILER_GCC);
  Info("Compiler CL:    %d", COMPILER_CL);
  Info("Compiler CLANG: %d", COMPILER_CLANG);

  Info("OS GNU/Linux:   %d", OS_LINUX);
  Info("OS BSD:         %d", OS_BSD);
  Info("OS MAC:         %d", OS_MAC);
  Info("OS Windows:     %d", OS_WINDOWS);

  Info("Architecture x86 32bit: %d", ARCH_X86);
  Info("Architecture x64 64bit: %d", ARCH_X64);
  Info("Architecture ARM 32bit: %d", ARCH_ARM32);
  Info("Architecture ARM 64bit: %d", ARCH_ARM64);
#endif

}
