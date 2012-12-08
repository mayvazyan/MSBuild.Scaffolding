# Copyright (c) Microsoft Corporation.  All rights reserved.

$knownExceptions = @(
)

<#
.SYNOPSIS
    Configures project to use SharedAssemblyInfo.cs.

.DESCRIPTION
	Adds reference to .\Build\SharedAssemblyInfo.cs and removes version related attributes from the AssemblyInfo.cs.    

.PARAMETER ProjectName
    Specifies the project that should be configured. If omitted, all the projects will be updated.
	Maybe the default project selected in package manager console should be used instead?
#>
function HasAssemblyVersion($project)
{
	foreach ($prop in $project.Properties) {
		if ($prop.Name -eq "AssemblyVersion") {
			return $true
		}			
	}
	return $false
}
function IsConfigured($project)
{
	if (!(HasAssemblyVersion $project)) {
		# it's ok we don't need to do anything with that project
		return $true
	}
	$fileName = "SharedAssemblyInfo.cs"
	
	foreach($file in $project.ProjectItems) {				
		if ($file.Name -eq $fileName) {
			return $true
		}
	}
	return $false;
}

function Enable-Versioning
{
	[CmdletBinding()] 
    param (
        [string] $ProjectName
    )
	$fileName = "SharedAssemblyInfo.cs"
	$solution = Get-Interface $dte.Solution ([EnvDTE80.Solution2])
	$solutionDirectoryName = [System.IO.Path]::GetDirectoryName($solution.FileName)
	$sharedAssemblyInfoPath = (Join-Path $solutionDirectoryName "Build\SharedAssemblyInfo.cs")
	
	foreach($project in $solution.Projects) {
		if (IsConfigured $project) {
			continue
		}
		
		Write-Host 'Configure ' . $project.Name

		# Add SharedAssemblyInfo.cs
		$project.ProjectItems.AddFromFile($sharedAssemblyInfoPath) | Out-Null		

		# Update Assembly Info
		$projectDirectoryName = [System.IO.Path]::GetDirectoryName($project.FullName)
		$assemblyInfoPath = Join-Path $projectDirectoryName "Properties\AssemblyInfo.cs"		
		(Get-Content $assemblyInfoPath) | Foreach-Object {
				$_ -replace '\[assembly\: AssemblyVersion\(', '//[assembly: AssemblyVersion(' `
				   -replace '\[assembly\: AssemblyFileVersion\(','//[assembly: AssemblyFileVersion('
				} | Set-Content $assemblyInfoPath
	}	
}

Export-ModuleMember @( 'Enable-Versioning')