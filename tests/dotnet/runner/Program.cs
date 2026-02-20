using Croicu.Templates.Test.Core;
using System.Reflection.Metadata;
using System.Runtime.InteropServices;

namespace Croicu.Templates.Test.Runner {

    public static class Program
    {
        public static int Main(string[] args)
        {
            int exitCode = 0;
            var factories = new Dictionary<string, RunnerBase>(StringComparer.OrdinalIgnoreCase)
            {
                ["Console"] = new ConsoleRunner(),
                ["GUI"]     = new GUIRunner(),
                ["Module"]  = new ModuleRunner(),
                ["Library"] = new LibraryRunner(),
            };

            if (!RuntimeInformation.IsOSPlatform(OSPlatform.Windows) &&
                !RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
            {
                Console.WriteLine($"[Error] Unsupported platform: {RuntimeInformation.OSDescription}");
                return -1;
            }

            foreach (TemplateInfo templateInfo in TemplateSettings.LoadTemplates())
            {
                string typeName = templateInfo.Type;

                if (!factories.TryGetValue(typeName, out var factory))
                {
                    Console.WriteLine($"[Error] Unknown template type '{typeName}'");

                    return -1;
                }

                exitCode = factory.Run(templateInfo);
                if (exitCode != 0)
                {
                    break;
                }
            }

            return exitCode;
        }
    }
}
