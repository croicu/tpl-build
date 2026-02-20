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
        [DynamicData(nameof(TemplateSettings.GetLibraries), typeof(TemplateSettings))]
        public void Execute(TemplateInfo templateInfo)
        {
            string zipPath = Path.Combine(Context.OutTemplatesDir, templateInfo.FileName);
            string stagingDir = Path.Combine(Context.TestDir, templateInfo.Name + ".staging");
            string destDir = Path.Combine(Context.TestDir, Context.Current.TestTemplate);

            Assert.IsTrue(Commands.Clean(stagingDir));
            Assert.IsTrue(Commands.Clean(destDir));
            Assert.IsTrue(Commands.Deploy(zipPath, stagingDir));
            Assert.IsTrue(Commands.VerifyDeployed(stagingDir, templateInfo.Files, false));
            Assert.IsTrue(Commands.InstantiateTemplate(stagingDir, destDir, templateInfo.Name, templateInfo.Files));
            Assert.IsTrue(Commands.VerifyDeployed(destDir, templateInfo.Files, true));

            if (Commands.ShouldBuild(templateInfo.Name, templateInfo.Platforms))
            {
                HostInfo hostInfo = TemplateHosts.GetByName(templateInfo.HostName);

                Assert.IsNotNull(hostInfo);
                Assert.IsTrue(Commands.InstantiateHost(Context.TestDir, templateInfo.HostName, Context.Current.TestTemplate));
                Assert.IsTrue(Commands.VerifyDeployed(Context.TestDir, hostInfo.Files, true));
                Assert.IsTrue(Commands.Build(Context.TestDir));
                Assert.IsTrue(Commands.VerifyBuilt(Context.TestOutDir, templateInfo.BuiltFiles));

                if (hostInfo.Executable != null)
                {
                    string hostExePath = Path.Combine(Context.TestOutDir, hostInfo.Executable.TargetFileName);

                    Assert.IsTrue(Commands.Execute(hostExePath));
                }
            }

            // Clean up
            Commands.Clean(stagingDir);
            Commands.Clean(destDir);
        }

        #endregion

        #region Private Methods

        #endregion
    }

} // namespace Croicu.Templates.Test.Integration 
