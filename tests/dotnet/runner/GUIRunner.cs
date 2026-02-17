using System;
using System.Collections.Generic;
using System.Security.Cryptography.X509Certificates;
using System.Text;

using Croicu.Templates.Test.Core;


namespace Croicu.Templates.Test.Runner
{
    internal class GUIRunner: RunnerBase
    {
        protected override int DoRun(TemplateInfo templateInfo)
        {
            bool enabled = true;

            if (enabled)
            {
                string zipPath = Path.Combine(Context.OutTemplatesDir, templateInfo.FileName);
                string stagingDir = Path.Combine(Context.TestDir, Context.Current.TestTemplate + ".staging");
                string destDir = Path.Combine(Context.TestDir, Context.Current.TestTemplate);

                Console.WriteLine($"[Info] Testing: {templateInfo.Name}...");

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
                    if (!Commands.VerifyBuilt(Context.TestTemplateOutDir, templateInfo.BuiltFiles))
                        return -1;

                    if (templateInfo.Executable != null)
                    {
                        string exePath = Path.Combine(Context.TestTemplateOutDir, templateInfo.Executable.TargetFileName);

                        if (!Commands.Execute(exePath))
                            return -1;
                    }
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
