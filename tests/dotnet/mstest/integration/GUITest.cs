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
    public class GUITest: TestBase
    {
        public GUITest(): base()
        {
        }

        #region Test Methods

        [TestMethod]
        [DynamicData(nameof(TemplateSettings.GetGUIs), typeof(TemplateSettings))]
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
                Assert.IsTrue(Commands.Build(destDir));
                Assert.IsTrue(Commands.VerifyBuilt(Context.TestTemplateOutDir, templateInfo.BuiltFiles));

                if (templateInfo.Executable != null)
                {
                    string exePath = Path.Combine(Context.TestTemplateOutDir, templateInfo.Executable.TargetFileName);

                    Assert.IsTrue(Commands.Execute(exePath));
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
