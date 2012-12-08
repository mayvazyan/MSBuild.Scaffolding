param($installPath, $toolsPath, $package, $project)

function AddItem($fileName, $buildFolder, $buildItems) {
	Copy-Item (Join-Path $toolsPath $fileName) $buildFolder | Out-Null
	$buildItems.AddFromFile((Join-Path $buildFolder $fileName))
}

function UpdateSolution($solution)
{
	# Get the solution name
	$solutionName = [System.IO.Path]::GetFileNameWithoutExtension($solution.FileName)
	$solutionDirectoryName = [System.IO.Path]::GetDirectoryName($solution.FileName)

	$buildFolder = (Join-Path $solutionDirectoryName "Build")	
	if (Test-Path $buildFolder){
		return $false; # already installed
	}

	# Create Build solution folder
	mkdir $buildFolder | Out-Null
	$buildProject = $solution.AddSolutionFolder("Build")
	$buildItems = Get-Interface $buildProject.ProjectItems ([EnvDTE.ProjectItems])
		
	# Add Build script
	$buildScriptPath = (Join-Path $solutionDirectoryName "$solutionName.proj");
	$msbuildScript = Get-Content "$toolsPath\msbuild.proj" | Foreach-Object {$_ -replace "YOUR_SOLUTION_NAME", $solutionName}
	Set-Content -Value $msbuildScript -Path $buildScriptPath
	$buildItems.AddFromFile($buildScriptPath)

	# Add some infrastructure
	AddItem "MSBuild.Community.Tasks.dll" $buildFolder $buildItems
	AddItem "MSBuild.Community.Tasks.Targets" $buildFolder $buildItems
	AddItem "SharedAssemblyInfo.cs" $buildFolder $buildItems
	AddItem "ReadMe.txt" $buildFolder $buildItems
	
	return $true;	
}

function ImportPowershellModule() {

	if ($PSVersionTable.PSVersion -ge (New-Object Version @( 3, 0 )))
	{
		$thisModuleManifest = 'MSBuild.Scaffolding.PS3.psd1'
	}
	else
	{
		$thisModuleManifest = 'MSBuild.Scaffolding.psd1'
	}
	
	$thisModule = Test-ModuleManifest (Join-Path $toolsPath $thisModuleManifest)	
	$name = $thisModule.Name
	
	$importedModule = Get-Module | ?{ $_.Name -eq $name }
	if ($importedModule)
	{
		if ($false -and $importedModule.Version -eq $thisModule.Version) 
		{
			return			
		}
		else 
		{
			Remove-Module $name			
		}    
	}
	Import-Module -Force -Global $thisModule
}

# Get the open solution.
$solution = Get-Interface $dte.Solution ([EnvDTE80.Solution2])

if (UpdateSolution $solution)
{
	Write-Host "Solution was prepared. Please run Enable-Versioning to configure projects to use SharedAssemblyInfo.cs"
}
else
{
	Write-Host "Build folder already exists... Please remove or rename it and then reinstall the package."
}

ImportPowershellModule
