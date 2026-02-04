using Croicu.Templates.Test.Core;
using Microsoft.Testing.Extensions.Telemetry;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Microsoft.VisualStudio.TestTools.UnitTesting.Logging;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Text.Json;

namespace Croicu.Templates.Test.Integration
{

    [TestClass]
    [TestCategory("Intergation")]
    public class ConsoleTest: TestBase
    {
        public ConsoleTest(): base()
        {
        }

        #region Test Methods

        [TestMethod]
        [DynamicData(nameof(TemplateSettings.GetConsole), typeof(TemplateSettings))]
        public void Execute(string templateName, string templateFileName, string hostName, TemplateFileInfo[] fileInfos)
        {
            string destDir = GetDestDir(templateName);
            string stagingDir = GetStagingDir(templateName);
            string zipPath = Path.Combine(Context.OutTemplatesDir, templateFileName);
            string exeName = templateName + ".exe";
            string pdbName = templateName + ".pdb";
            string exePath = Path.Combine(Context.TestTemplateOutBinDir, exeName);

            Assert.IsTrue(Commands.Clean(GetStagingDir(templateName)));
            Assert.IsTrue(Commands.Clean(GetDestDir(templateName)));
            Assert.IsTrue(Commands.Deploy(zipPath, stagingDir));
            Assert.IsTrue(Commands.VerifyDeployed(stagingDir, fileInfos));
            Assert.IsTrue(Commands.InstantiateTemplate(stagingDir, destDir, templateName, fileInfos));
            Assert.IsTrue(Commands.VerifyDeployed(destDir, fileInfos));
            Assert.IsTrue(Commands.Build(destDir));
            Assert.IsTrue(Commands.VerifyBuilt(Context.TestTemplateOutBinDir, [exeName, pdbName]));
            Assert.IsTrue(Commands.Execute(exePath));
            
            // Clean up
            Commands.Clean(GetStagingDir(templateName));
            Commands.Clean(GetDestDir(templateName));
        }

        #endregion

        #region Private Methods

        private static string GetStagingDir(string templateName)
        {
            return Path.Combine(Context.TestDir, templateName + ".staging");
        }

        private static string GetDestDir(string templateName)
        {
            return Path.Combine(Context.TestDir, templateName);
        }

        private static bool Clean(String destDir)
        {

            if (Directory.Exists(destDir))
            {
                try
                {
                    Directory.Delete(destDir, true);
                }
                catch (Exception ex)
                {
                    Logger.LogMessage($"Failed to delete {destDir}\nError: {ex.Message}.");
                    return false;
                }
            }

            return true;
        }

        private void Deploy(string zipPath, string stagingDir)
        {
            Logger.LogMessage($"Start deploying {Path.GetFileName(zipPath)} template.");
            Assert.IsTrue(File.Exists(zipPath));

            try
            {
                TemplateExpander.ExpandToDirectory(zipPath, stagingDir);
                TestContext.WriteLine($"Expanded: {zipPath} -> {stagingDir}");
            }
            catch (FileNotFoundException)
            {
                TestContext.WriteLine($"File not found: {zipPath}.");

                return;
            }

            return;
        }

        private void VerifyDeployed(TemplateFileInfo[] fileInfos, string stagingDir)
        {
            foreach (TemplateFileInfo fileInfo in fileInfos)
            {
                string filePath = Path.Combine(stagingDir, fileInfo.FileName);

                if (File.Exists(filePath))
                    Logger.LogMessage($"File {fileInfo.FileName}, exist.");
                else
                    Logger.LogMessage($"File {fileInfo.FileName}, not found");

                Assert.IsTrue(File.Exists(filePath));
            }
        }

        private bool CheckFiles(string destDir, TemplateInfo templateInfo)
        {
            foreach (TemplateFileInfo fileInfo in templateInfo.Files)
            {
                string filePath = Path.Combine(destDir, fileInfo.FileName);

                if (File.Exists(filePath))
                {
                    TestContext.WriteLine($"    Found file: {filePath}.");
                }
                else
                {
                    TestContext.WriteLine($"    File not found: {filePath}.");
                    return false;
                }
            }

            return true;
        }

        private void Instantiate(TemplateInfo templateInfo, string stagingDir, string destDir)
        {
            TemplateInstantiator.Instantiate(stagingDir, destDir, templateInfo.Name, templateInfo.Files);
        }

        private int Build(string destDir)
        {
            int exitCode = Builder.Build("cmd.exe", destDir, "/c build.bat");

            if (exitCode != 0)
            {
                TestContext.WriteLine($"Build failed, exit code: {exitCode}.");
            }

            return exitCode;
        }

        private int Execute(string exePath)
        {
            string? exeDir = Path.GetDirectoryName(exePath);

            if (exeDir == null || !Directory.Exists(exeDir) || !File.Exists(exePath))
                return -1;

            int exitCode = Executor.Execute(exePath, exeDir);

            if (exitCode != 0)
            {
                TestContext.WriteLine($"Execute failed, exit code: {exitCode}.");
            }

            return exitCode;
        }

        #endregion
    }

} // namespace Croicu.Templates.Test.Integration 
