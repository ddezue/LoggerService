param(
    [string]$CsprojPath,
    [string]$Workspace
)

$csproj = $CsprojPath
$xml = [xml](Get-Content $csproj -Encoding UTF8)

if (-not $xml.Project.Sdk) {
    Write-Host "Обнаружен старый формат csproj (не SDK). Конвертируем..."
    Copy-Item $csproj -Destination "$csproj.bak" -Force

    # Собираем ссылки на сборки (Reference) – только те, у которых есть непустой Include
    $references = $xml.Project.ItemGroup.Reference | 
        Where-Object { $_.Include -and $_.Include.Trim() -ne "" } | 
        ForEach-Object { "    <Reference Include=`"$($_.Include)`" />" }
    $refBlock = if ($references) { $references -join "`n" } else { "" }

    # Собираем все файлы Compile (явно перечисляем, отключая авто-включение)
    $compiles = $xml.Project.ItemGroup.Compile | 
        Where-Object { $_.Include -and $_.Include.Trim() -ne "" } | 
        ForEach-Object { "    <Compile Include=`"$($_.Include)`" />" }
    $compileBlock = if ($compiles) { $compiles -join "`n" } else { "" }

    # Собираем все None (например, App.config)
    $nones = $xml.Project.ItemGroup.None | 
        Where-Object { $_.Include -and $_.Include.Trim() -ne "" } | 
        ForEach-Object { "    <None Include=`"$($_.Include)`" />" }
    $noneBlock = if ($nones) { $nones -join "`n" } else { "" }

    $newCsproj = @"
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net472</TargetFramework>
    <OutputType>Exe</OutputType>
    <RootNamespace>ExpeditionPlanner</RootNamespace>
    <AssemblyName>ExpeditionPlanner</AssemblyName>
    <GenerateAssemblyInfo>false</GenerateAssemblyInfo>
    <LangVersion>latest</LangVersion>
    <EnableDefaultCompileItems>false</EnableDefaultCompileItems>
    <EnableDefaultNoneItems>false</EnableDefaultNoneItems>
  </PropertyGroup>
  <ItemGroup>
$refBlock
  </ItemGroup>
  <ItemGroup>
$compileBlock
  </ItemGroup>
  <ItemGroup>
$noneBlock
  </ItemGroup>
  <ItemGroup>
    <PackageReference Include="StyleCop.Analyzers" Version="1.2.0-beta.556">
      <PrivateAssets>all</PrivateAssets>
      <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
    </PackageReference>
  </ItemGroup>
</Project>
"@
    $newCsproj | Out-File -FilePath $csproj -Encoding utf8
    Write-Host "Проект успешно конвертирован в SDK-стиль, StyleCop.Analyzers добавлен."
} else {
    Write-Host "Проект уже в SDK-стиле. Добавляем StyleCop.Analyzers через PackageReference."
    $ns = $xml.DocumentElement.NamespaceURI
    $itemGroup = $xml.Project.ItemGroup | Where-Object { $_.PackageReference -and $_.PackageReference.Count -gt 0 }
    if (-not $itemGroup) {
        $itemGroup = $xml.CreateElement("ItemGroup", $ns)
        $xml.Project.AppendChild($itemGroup) | Out-Null
    }
    $exists = $itemGroup.PackageReference | Where-Object { $_.Include -eq "StyleCop.Analyzers" }
    if (-not $exists) {
        $package = $xml.CreateElement("PackageReference", $ns)
        $package.SetAttribute("Include", "StyleCop.Analyzers")
        $package.SetAttribute("Version", "1.2.0-beta.556")
        $itemGroup.AppendChild($package) | Out-Null
        $xml.Save($csproj)
        Write-Host "PackageReference добавлен."
    }
}