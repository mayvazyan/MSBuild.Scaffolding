# Copyright (c) Microsoft Corporation.  All rights reserved.

$knownExceptions = @(
)

<#
.SYNOPSIS
	Configures project to use SharedAssemblyInfo.cs.

.DESCRIPTION
	Adds reference to .\Build\SharedAssemblyInfo.cs and removes version related attributes from the AssemblyInfo.cs.    

.PARAMETER ProjectName
    Specifies the project that should be configured. If omitted, all the supported projects will be updated.
#>
function IsConfigured($project)
{	
	$fileName = "SharedAssemblyInfo.cs"
	
	foreach($file in $project.ProjectItems) {				
		if ($file.Name -eq $fileName) {
			return $true
		}
	}
	return $false;
}
function ConfigureProject($project)
{
	if (IsConfigured $project) {
		return
	}		
	Write-Host Configure $project.Name

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

function ProcessProject($project, $projectToConfigure)
{
	$kind = $project.Kind.ToString() # http://msdn.microsoft.com/en-us/library/hb23x61k(v=vs.80).aspx
	if ($kind -eq "{66A26720-8FB5-11D2-AA7E-00C04F688DDE}") # Solution Folder
	{
		foreach ($p in $project.ProjectItems) 
		{
			if ($p.SubProject)
			{
				ProcessProject $p.SubProject $projectToConfigure
			}
		}
	}
	else 
	{	
		if (!($projectToConfigure -eq "" -or $projectToConfigure -eq $project.Name))
		{
			return
		}
		if ($kind -eq "{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") # Visual C#
		{
			ConfigureProject $project
		}
		else
		{ 
			Write-Host Project Ignored $project.Name - project type isn''t supported
		}
	}		
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
		ProcessProject $project $ProjectName
	}	
}

Export-ModuleMember @( 'Enable-Versioning')