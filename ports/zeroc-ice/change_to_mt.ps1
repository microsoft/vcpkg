
$projFilePath = $args[0]
$crtLinkage = $args[1]

if($projFilePath)
{
  $xpath = "/rs:Project/rs:ItemGroup/rs:ProjectConfiguration"
  $xmldoc = New-Object System.Xml.XmlDocument
  $xmldoc.load($projFilePath)
  $nsmgr = New-Object System.Xml.XmlNamespaceManager($xmldoc.NameTable);
  $nsmgr.AddNamespace("rs", "http://schemas.microsoft.com/developer/msbuild/2003");
  $root = $xmldoc.DocumentElement

  foreach($conf in $root.ItemDefinitionGroup)
  {
    if($conf.Condition)
    {
      if(-Not ($conf.ClCompile.RuntimeLibrary))
      {
        $rtl = $xmldoc.CreateElement("RuntimeLibrary", $conf.ClCompile.NamespaceURI)
        $conf.ClCompile.AppendChild($rtl)
      }

      if($conf.Condition.Contains("Debug"))
      {
        if($crtLinkage -eq "static")
        {
          $conf.ClCompile.RuntimeLibrary = "MultithreadedDebug"
        }
        else
        {
          $conf.ClCompile.RuntimeLibrary = "MultithreadedDebugDLL"
        }
      }
      else
      {
        if($crtLinkage -eq "static")
        {
          $conf.ClCompile.RuntimeLibrary = "Multithreaded"
        }
        else
        {
          $conf.ClCompile.RuntimeLibrary = "MultithreadedDLL"
        }
      }
    }
  }
  $xmldoc.save($projFilePath)
}
else
{
  Write-Error "Error: No path defined!"
}
