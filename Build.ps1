param(
    [Parameter(Mandatory=$true)][string]$OutputDirectory,
    [switch]$LogFormattingTest
)
$ErrorActionPreference = 'Stop'
# Run in an MSVC x86 development environment (VS 2022 / Windows 10 SDK).
$compiler = (Get-Command cl.exe -ErrorAction Stop).Source
$sourceRoot = $PSScriptRoot
$outputRoot = [IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null
[xml]$project = Get-Content -LiteralPath "$sourceRoot\CSOLauncher.vcxproj"
$sources = @($project.Project.ItemGroup.ClCompile | Where-Object { $_.Include } | ForEach-Object { "$sourceRoot\$($_.Include)" })
if ($LogFormattingTest) { $sources += "$sourceRoot\log-format-test.cpp" }
$compileArgs = @('/nologo', '/W3', '/O2', '/Oi', '/Gy', '/GL', '/Zi', '/MT', '/EHsc', '/sdl', '/MP', '/DWIN32', '/DNDEBUG', '/D_CONSOLE', '/D_MBCS', '/D_CRT_SECURE_NO_WARNINGS', '/D_CRT_NONSTDC_NO_DEPRECATE', '/D_CRT_NON_CONFORMING_SWPRINTFS', "/I$sourceRoot\Interface", "/I$sourceRoot\HLSDK\common", "/I$sourceRoot\HLSDK\engine", "/I$sourceRoot\HLSDK\cl_dll", "/Fo$outputRoot\", "/Fd$outputRoot\compiler.pdb", "/Fe$outputRoot\CSOLauncher.exe")
$linkArgs = @('/link', '/SUBSYSTEM:WINDOWS', '/MACHINE:X86', '/LARGEADDRESSAWARE', '/DEBUG', '/OPT:REF', '/OPT:ICF', '/INCREMENTAL:NO', "/PDB:$outputRoot\CSOLauncher.pdb", 'ws2_32.lib', 'kernel32.lib', 'user32.lib', 'gdi32.lib', 'winspool.lib', 'comdlg32.lib', 'advapi32.lib', 'shell32.lib', 'ole32.lib', 'oleaut32.lib', 'uuid.lib', 'odbc32.lib', 'odbccp32.lib')
if ($LogFormattingTest) { $linkArgs[1] = '/SUBSYSTEM:CONSOLE' }
Push-Location -LiteralPath $sourceRoot
try {
    & $compiler @compileArgs @sources @linkArgs
    if ($LASTEXITCODE -ne 0) { throw "Compiler exited with $LASTEXITCODE" }
    Get-FileHash -Algorithm SHA256 -LiteralPath "$outputRoot\CSOLauncher.exe"
} finally { Pop-Location }
