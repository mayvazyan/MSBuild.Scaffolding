1. How to run build script?
Build script could be run using msbuild console application. The simlest way to call it is by using Visual Studio command promt.
ex. "msbuild [YourSolutionName].proj". (The actual file name could be seen in the "Build" solution folder)

2. Build Targets
Default build script target set to Build. So in most cases on build server you'll want to run Publish target. It could easily done by specifying /t:Publish argument.
ex. "msbuild [YourSolutionName].proj /t:Publish"

3. Assembly version
Build Number and Revision could be passed to build script using BuildNumber & SourceGetVersion arguments.
ex. "msbuild [YourSolutionName].proj /t:Publish /p:BuildNumber=1 /p:SourceGetVersion=101"