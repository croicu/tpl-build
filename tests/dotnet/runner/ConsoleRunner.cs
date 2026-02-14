using System;
using System.Collections.Generic;
using System.Security.Cryptography.X509Certificates;
using System.Runtime.InteropServices;
using System.Text;

using Croicu.Templates.Test.Core;


namespace Croicu.Templates.Test.Runner
{
    internal class ConsoleRunner: RunnerBase
    {
        protected override int DoRun(TemplateInfo templateInfo)
        {
            bool enabled = true;

            if (enabled)
            {
                string zipPath = Path.Combine(Context.OutTemplatesDir, templateInfo.FileName);
                string stagingDir = Path.Combine(Context.TestDir, templateInfo.Name + ".staging");
                string destDir = Path.Combine(Context.TestDir, Context.Current.TestTemplate);
                string exeName;
                string exePath;

                Console.WriteLine($"[Info] Testing: {templateInfo.Name}...");

                if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
                {
                    exeName = templateInfo.Name + ".exe";
                    exePath = Path.Combine(Context.TestTemplateOutBinDir, exeName);
                }
                else
                {
                    exeName = templateInfo.Name;
                    exePath = Path.Combine(Context.TestTemplateOutBinDir, exeName);
                }
                
                if (!Commands.Clean(stagingDir))
                    return -1;
                if (!Commands.Clean(destDir))
                    return -1;
                if (!Commands.Deploy(zipPath, stagingDir))
                    return -1;
                if (!Commands.VerifyDeployed(stagingDir, templateInfo.Files, false))
                    return -1;
                if (!Commands.InstantiateTemplate(stagingDir, destDir, templateInfo.Name, templateInfo.Files))
                    return -1;
                if (!Commands.VerifyDeployed(destDir, templateInfo.Files, true))
                    return -1;
                if (Commands.ShouldBuild(templateInfo.Name, templateInfo.Platforms))
                {
                    if (!Commands.Build(destDir))
                        return -1;
                    if (!Commands.VerifyBuilt(Context.TestTemplateOutBinDir, templateInfo.BuiltFiles))
                        return -1;
                    if (!Commands.Execute(exePath))
                        return -1;
                }

                // If we reached this point, all commands were successful
                Commands.Clean(stagingDir);
                Commands.Clean(destDir);

                Console.WriteLine($"[Info] Testing: {templateInfo.Name}. Success.");
            }

            return 0;
        }

        #region Private Methods

        #endregion

    }
}
