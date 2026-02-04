using Croicu.Templates.Test.Core;
using System;
using System.Collections.Generic;
using System.Text;

namespace Croicu.Templates.Test.Runner
{
    internal class ModuleRunner: RunnerBase
    {
        protected override int DoRun(TemplateInfo templateInfo)
        {
            bool enabled = true;

            if (enabled)
            {
                string zipPath = Path.Combine(Context.OutTemplatesDir, templateInfo.FileName);
                string stagingDir = Path.Combine(Context.TestDir, templateInfo.Name + ".staging");
                string destDir = Path.Combine(Context.TestDir, templateInfo.Name);
                string hostName = templateInfo.HostName + ".exe";
                string dllName = templateInfo.Name + ".dll";
                string pdbName = templateInfo.Name + ".pdb";
                string libName = templateInfo.Name + ".lib";
                string headerName = "module.h";
                string dllPath = Path.Combine(Context.TestTemplateOutBinDir, dllName);
                string hostPath = Path.Combine(Context.TestOutBinDir, hostName);

                Console.WriteLine($"[Info] Testing: {templateInfo.Name}...");

                if (!Commands.Clean(stagingDir) ||
                    !Commands.Clean(destDir) ||
                    !Commands.Deploy(zipPath, stagingDir) ||
                    !Commands.VerifyDeployed(stagingDir, templateInfo.Files) ||
                    !Commands.InstantiateTemplate(stagingDir, destDir, templateInfo.Name, templateInfo.Files) ||
                    !Commands.VerifyDeployed(destDir, templateInfo.Files) ||
                    !Commands.Build(destDir) ||
                    !Commands.VerifyBuilt(Context.TestTemplateOutBinDir, [dllName, pdbName]) ||
                    !Commands.VerifyBuilt(Context.TestTemplateOutLibDir, [libName]) ||
                    !Commands.VerifyBuilt(Context.TestTemplateOutIncludeDir, [headerName]) ||
                    !Commands.Invoke(dllPath) ||
                    !Commands.InstantiateHost(Context.TestDir, templateInfo.HostName, templateInfo.Name) ||
                    !Commands.VerifyDeployed(Context.TestDir, TemplateHosts.GetByName(templateInfo.HostName).Files) ||
                    !Commands.Build(Context.TestDir) ||
                    !Commands.VerifyBuilt(Context.TestOutBinDir, [hostName, dllName, pdbName]) ||
                    !Commands.VerifyBuilt(Context.TestOutLibDir, [libName]) ||
                    !Commands.VerifyBuilt(Context.TestOutIncludeDir, [headerName]) ||
                    !Commands.Execute(hostPath))
                {
                    return -1;
                }

                // If we reached this point, all commands were successful
                Commands.Clean(stagingDir);
                Commands.Clean(destDir);

                Console.WriteLine($"[Info] Testing: {templateInfo.Name}. Success.");
            }

            return 0;
        }
    }
}
