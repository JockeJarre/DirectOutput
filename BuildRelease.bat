@echo off
rem   DirectOutput Reecho >echo >>> Buildiecho ^>^>^> Building WiX 6 x64 MSI installer
wix build -arch x64 -d Platform=x64 -d Configuration=Release -ext WixToolset.UI.wixext -o "DOFSetup\bin\x64\Release\DOFSetup.msi" DOFSetup\Product.wxs
if errorlevel 1 goto abortWiX 6 x64 MSI installer
wix build -arch x64 -d Platform=x64 -ext WixToolset.UI.wixext -o "DOFSetup\bin\x64\Release\DOFSetup.msi" DOFSetup\Product.wxs Building WiX 6 x86 MSI installer
wix build -arch x86 -d Platform=x86 -ext WixToolset.UI.wixext -o "DOFSetup\bin\x86\Release\DOFSetup.msi" DOFSetup\Product.wxsase Builder script

if %1# == # (
  echo usage: BuildRelease ^<author-tag^>
  echo.
  echo ^<author-tag^> is a short identifier, such as your initials, that will be embedded
  echo in the .msi and .zip filenames to help identify the source of the build files, if you
  echo plan to distribute them.
  goto EOF
)

rem Clean the release configurations
echo ^>^>^> Removing old builds
msbuild DirectOutput.sln -t:Clean -p:Configuration=Release;Platform=x86 -v:q -nologo
if errorlevel 1 goto abort
msbuild DirectOutput.sln -t:Clean -p:Configuration=Release;Platform=x64 -v:q -nologo
if errorlevel 1 goto abort

rem Build the release configurations
echo.
echo ^>^>^> Building Release^|x86
msbuild DirectOutput.sln -t:Build -p:Configuration=Release;Platform=x86 -v:q -nologo
if errorlevel 1 goto abort

echo.
echo ^>^>^> Building Release^|x64
msbuild DirectOutput.sln -t:Build -p:Configuration=Release;Platform=x64 -v:q -nologo
if errorlevel 1 goto abort

rem Build WiX 6 MSI installers
echo.
echo ^>^>^> Building custom actions for x86
dotnet build DOFSetupB2SFixup\DOFSetupB2SFixup.csproj -c Release -p:Platform=x86 -v:q --nologo
if errorlevel 1 goto abort
dotnet build DOFSetupPBXFixup\DOFSetupPBXFixup.csproj -c Release -p:Platform=x86 -v:q --nologo
if errorlevel 1 goto abort

echo.
echo ^>^>^> Building WiX 6 x86 MSI installer
wix build -arch x86 -d Platform=x86 -d Configuration=Release -ext WixToolset.UI.wixext -o "DOFSetup\bin\x86\Release\DOFSetup.msi" DOFSetup\Product.wxs
if errorlevel 1 goto abort

echo.
echo ^>^>^> Building custom actions for x64
dotnet build DOFSetupB2SFixup\DOFSetupB2SFixup.csproj -c Release -p:Platform=x64 -v:q --nologo
if errorlevel 1 goto abort
dotnet build DOFSetupPBXFixup\DOFSetupPBXFixup.csproj -c Release -p:Platform=x64 -v:q --nologo
if errorlevel 1 goto abort

echo.
echo ^>^>^> Building WiX 6 x64 MSI installer
wix build -arch x64 -d Platform=x64 -ext WixToolset.UI.wixext -o "DOFSetup\bin\x64\Release\DOFSetup.msi" DOFSetup\Product_WiX6.wxs
if errorlevel 1 goto abort

rem Build the release files
echo.
echo ^>^>^> Creating release packages in .\Builds
call MakeZip x86 release %1
call MakeZip x64 release %1
 
rem successful completion
echo === Build completed successfully ===
goto EOF


:abort
echo MSBUILD exited with error - aborted

:EOF
