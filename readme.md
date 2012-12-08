# MSBuild.Scaffolding
Powershell package that adds basic MSBuild script and required infrastructure to your solution.

## Features
* Creates basic build script that could be used in CI or DEV builds.
* Updates `SharedAssemblyInfo.cs` by the prober build and revision number during each build (by using MSBuildCommunity tasks)
* `Enable-Versioning` cmdlet allows to easily configure solution projects to use SharedAssemblyInfo.cs.

### How to run build script?
`msbuild {BUILD_SCRIPT_NAME}.proj /p:BuildNumber=1 /p:RevisionNumber=22 /t:publish`

### Enable-Versioning explained
* In Visual Studio please open Package Manager Console
* Type `Enable-Versioning` and hit Enter - all the projects in the solution will be configured to use version from the SharedAssemblyInfo.cs
* Type `Enable-Versioning {PROJECT_NAME}` and hit Enter - only specified project will be configured to use version from the SharedAssemblyInfo.cs

## Notes
Please note that this package is the solution level package. It will be added to the solution itself. 
It won't be downloaded by the NuGet Package Restore feature. Hence all the needed files are being added into Build folder.
In order to use Enable-Versioning cmdlet package should be installed.

## Copyright

Copyright © 2012 Michael Ayvazyan

## License

MSBuild.Scaffolding is licensed under [MIT](http://www.opensource.org/licenses/mit-license.php "Read more about the MIT license form"). Refer to license.txt for more information.
