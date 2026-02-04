using System;
using System.Collections.Generic;
using System.Security.Cryptography.X509Certificates;
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
                string destDir = Path.Combine(Context.TestDir, templateInfo.Name);
                string exeName = templateInfo.Name + ".exe";
                string pdbName = templateInfo.Name + ".pdb";
                string exePath = Path.Combine(Context.TestTemplateOutBinDir, exeName);

                Console.WriteLine($"[Info] Testing: {templateInfo.Name}...");

                if (!Commands.Clean(stagingDir) ||
                    !Commands.Clean(destDir) ||
                    !Commands.Deploy(zipPath, stagingDir) ||
                    !Commands.VerifyDeployed(stagingDir, templateInfo.Files) ||
                    !Commands.InstantiateTemplate(stagingDir, destDir, templateInfo.Name, templateInfo.Files) ||
                    !Commands.VerifyDeployed(destDir, templateInfo.Files) ||
                    !Commands.Build(destDir) ||
                    !Commands.VerifyBuilt(Context.TestTemplateOutBinDir, [exeName, pdbName]) ||
                    !Commands.Execute(exePath))
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

        #region Private Methods

        #endregion

    }
}
