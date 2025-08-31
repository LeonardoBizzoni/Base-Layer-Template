#include "cbuild.h"

#define BaseLayerOutfile "main"
#define BaseLayerInput   "main.c"

#if OS_WINDOWS
#  define SystemSharedLibs "/link", "ws2_32.lib", "winmm.lib", \
                                    "advapi32.lib", "hid.lib", \
                                    "user32.lib"
#  define GenericFlags "/Zc:preprocessor", "/GA", "/Gw", \
                       "/permissive", "/fastfail", "/sdl"
#  define ReleaseFlags "/O2", "/Ot", "/Ob3", "/GL", "/Qpar", \
                       "/Qspectre-load"
#  define DebugFlags "/Od", "/Zi", "/fsanitize=address", \
                     "/RTC1", "/DDEBUG=1", "/DENABLE_ASSERT=1"
#  define SharedLibFlags "/LD", "/DLL", "/DNO_MAIN=1"
#  define CppFlags "/TP", "/std:c++latest"
#  define CAnnoyingWarnings "/wd4477", "/wd4996"
#  define CppAnnoyingWarnings CAnnoyingWarnings
#  define OpenglFlags "gdi32.lib", "opengl32.lib"
#  define Codebase_Path "/I./src/base"
#  define Codebase_Module_Gui "/DOS_GUI=1"
#  define Codebase_Module_Sound "/DOS_SOUND=1"
#  define BaseLayerOutput "/Fe:" BaseLayerOutfile
#else
#  define SystemSharedLibs "-lpthread", "-lm"
#  define SharedLibFlags "-shared", "-fPIC"
#  define GenericFlags "-pedantic", "-Wall", "-Werror", "-Wextra",         \
                       "-Wconversion", "-Wdouble-promotion",               \
                       "-Wundef", "-Wcast-qual", "-Wmissing-declarations", \
                       "-Wredundant-decls"
#  define ReleaseFlags "-O3", "-s", "-march=native", "-flto", \
                       "-D_FORTIFY_SOURCE=2", "-Wno-unused-variable"
#  define DebugFlags "-O0", "-g3", "-ggdb", "-DENABLE_ASSERT=1",       \
                     "-DDEBUG=1", "-fsanitize=address,undefined,leak", \
                     "-fsanitize-trap", "-fstack-protector-strong"
#  define CppFlags "-std=c++23", "-fno-exceptions"
#  define CAnnoyingWarnings "-Wno-unused-function",                   \
                            "-Wno-initializer-overrides",             \
                            "-Wno-c23-extensions",                    \
                            "-Wno-gnu-zero-variadic-macro-arguments", \
                            "-Wno-sign-conversion",                   \
                            "-Wno-unused-parameter",                  \
                            "-Wno-unused-variable",                   \
                            "-Wno-unused-but-set-variable",           \
                            "-Wno-cast-qual"
#  define CppAnnoyingWarnings CAnnoyingWarnings            \
                              "-Wno-gnu-anonymous-struct", \
                              "-Wno-nested-anon-types"
#  define Codebase_Path "-I./src/base"
#  define Codebase_Module_Gui "-DOS_GUI=1"
#  define Codebase_Module_Sound "-DOS_SOUND=1", "-lpulse"
#  define BaseLayerOutput "-o" BaseLayerOutfile

#  define OpenglFlags "-lEGL", "-lGLESv2", "-DGFX_OPENGL=1"
#  define VulkanFlags "-lvulkan", "-DGFX_VULKAN=1"
#  if OS_LINUX
#    define X11 "-DLNX_X11=1", "-lX11", "-lXext"
#    define Wayland "-DLNX_WAYLAND=1", "-lwayland-client", "-lxkbcommon"
#    define Wayland_OpenGl "-lwayland-egl"
#  elif OS_BSD
#    define X11 "-DBSD_X11=1", "-lX11", "-lXext"
#    define Wayland "-DBSD_WAYLAND=1", "-lxkbcommon"
#  elif OS_MAC
#    error I dont have a mac
#  endif
#endif

int main(int argc, char **argv) {
  cb_rebuild_self(argc, argv);
}
