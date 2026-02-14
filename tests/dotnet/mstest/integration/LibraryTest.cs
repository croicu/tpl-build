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
    public class LibraryTest: TestBase
    {
        public LibraryTest(): base()
        {
        }

        #region Test Methods

        [TestMethod]
        [DynamicData(nameof(TemplateSettings.GetLibrary), typeof(TemplateSettings))]
        public void Execute(string templateName, string templateFileName, string hostName, string[] platforms, TemplateFileInfo[] templateFiles, TemplateFileInfo[] builtFiles)
        {
            string destDir = GetDestDir(templateName);
            string stagingDir = GetStagingDir(templateName);
            string zipPath = Path.Combine(Context.OutTemplatesDir, templateFileName);
            string hostFileName = hostName + ".exe";
            string libName = templateName + ".lib";
            string hostPath = Path.Combine(Context.TestOutBinDir, hostFileName);

            Assert.IsTrue(Commands.Clean(GetStagingDir(templateName)));
            Assert.IsTrue(Commands.Clean(GetDestDir(templateName)));
            Assert.IsTrue(Commands.Deploy(zipPath, stagingDir));
            Assert.IsTrue(Commands.VerifyDeployed(stagingDir, templateFiles, false));
            Assert.IsTrue(Commands.InstantiateTemplate(stagingDir, destDir, templateName, templateFiles));
            Assert.IsTrue(Commands.VerifyDeployed(destDir, templateFiles, true));
            if (Commands.ShouldBuild(templateName, platforms))
            {
                Assert.IsTrue(Commands.Build(destDir));
                Assert.IsTrue(Commands.VerifyBuilt(Context.TestTemplateOutDir, builtFiles));
                Assert.IsTrue(Commands.InstantiateHost(Context.TestDir, hostName, templateName));
                Assert.IsTrue(Commands.VerifyDeployed(Context.TestDir, TemplateHosts.GetByName(hostName).Files, true));
                Assert.IsTrue(Commands.Build(Context.TestDir));
                Assert.IsTrue(Commands.VerifyBuilt(Context.TestOutDir, builtFiles));
                Assert.IsTrue(Commands.Execute(hostPath));
            }
            
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
