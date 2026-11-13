#include <cstdarg>
#include <cstdio>
#include <cstring>
#include <string>

extern void (__cdecl* g_pfnLogToErrorLog)(void*, char*, ...);
extern void __cdecl Hook_LogToErrorLog(void*, char*, ...);
extern unsigned long __cdecl Hook_GetPECompilationTime(const char*);
static std::string captured;
static bool safeForward = false;
static void __cdecl Capture(void*, char* format, ...)
{
    safeForward = strcmp(format, "%s") == 0;
    va_list args;
    va_start(args, format);
    captured = va_arg(args, const char*);
    va_end(args);
}
int main()
{
    g_pfnLogToErrorLog = Capture;
    std::string oversized(8192, 'x');
    Hook_LogToErrorLog(nullptr, const_cast<char*>("%s"), oversized.c_str());
    if (!safeForward || captured.size() != 4095) return 1;
    Hook_LogToErrorLog(nullptr, const_cast<char*>("progress %d%%; literal %%s"), 100);
    if (!safeForward || captured != "progress 100%; literal %s") return 2;
    if (Hook_GetPECompilationTime("cstrike-online.exe") != 0x6588118B) return 3;
    if (Hook_GetPECompilationTime("CSOLauncher.exe") != 0x6588118B) return 4;
    puts("\nPASS: long logs, percent escaping, legacy wire build date");
    return 0;
}
