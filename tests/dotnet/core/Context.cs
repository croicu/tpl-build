using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text;

namespace Croicu.Templates.Test.Core
{
    public static class Context
    {
        public class LocalContext
        {
            public LocalContext()
            {
            }

            public void Done()
            {
                Context.s_current.Value = null;
            }

            public string? TestClassName { get; set; }
            public string? TestName { get; set; }
            public string? TestTemplate { get; set; }
        }

        public static string RepoRoot => s_env.Value.RepoRoot;

        public static string Arch => CommandLine.Arch;
        public static string Config => CommandLine.Config;

        public static string BuildDir => Path.Combine(RepoRoot, "build", Arch, Config);

        public static string OutDir => Path.Combine(RepoRoot, "out", Arch, Config);
        public static string OutIncludeDir => Path.Combine(OutDir, "include");
        public static string OutTemplatesDir => Path.Combine(OutDir, "templates");
        public static string OutBinDir => Path.Combine(OutDir, "bin");
        public static string OutLibDir => Path.Combine(OutDir, "lib");

        public static string TestDataDir => Path.Combine(RepoRoot, "tests", "data");
        public static string TestHostsDir => Path.Combine(TestDataDir, "hosts");
        public static string TestSettingsDir => Path.Combine(TestDataDir, "settings");

        public static string TestRoot => Path.Combine(BuildDir, "test");

        public static string TestDir
        {
            get
            {
                if (s_current.Value != null && 
                    s_current.Value.TestClassName != null && 
                    s_current.Value.TestName != null)
                {
                    return Path.Combine(TestRoot, s_current.Value.TestClassName, s_current.Value.TestName);
                }

                return Path.Combine(TestRoot, "TestClass", "TestName");
            }
        }

        public static string TestBuildDir => Path.Combine(TestDir, "build", Arch, Config);
        public static string TestOutDir => Path.Combine(TestDir, "out", Arch, Config);
        public static string TestOutIncludeDir => Path.Combine(TestOutDir, "include");
        public static string TestOutBinDir => Path.Combine(TestOutDir, "bin");
        public static string TestOutLibDir => Path.Combine(TestOutDir, "lib");

        public static string TestTemplateDir
        {
            get
            {
                if (s_current.Value != null &&
                    s_current.Value.TestTemplate != null)
                {
                    return Path.Combine(TestDir, s_current.Value.TestTemplate);
                }

                return Path.Combine(TestDir, "TestTemplate");
            }
        }

        public static string TestTemplateBuildDir => Path.Combine(TestTemplateDir, "build", Arch, Config);
        public static string TestTemplateOutDir => Path.Combine(TestTemplateDir, "out", Arch, Config);
        public static string TestTemplateOutIncludeDir => Path.Combine(TestTemplateOutDir, "include");
        public static string TestTemplateOutBinDir => Path.Combine(TestTemplateOutDir, "bin");
        public static string TestTemplateOutLibDir => Path.Combine(TestTemplateOutDir, "lib");

        public static ILogger Logger
        {
            get
            {
                if (s_logger == null)
                    s_logger = new Logger();
                return s_logger;
            }
            set
            {
                s_logger = value;
            }
        }

        public static LocalContext Current
        {
            get
            {
                if (s_current.Value == null)
                {
                    s_current.Value = new LocalContext();
                }

                return s_current.Value;
            }
        }

        #region Private Classes

        private sealed record Env(string RepoRoot);

        private static class CommandLine
        {
            static CommandLine()
            {
                var exe = System.Environment.GetCommandLineArgs()[0];
                var fullPath = Path.GetFullPath(exe);

                ProcessCommandLine(fullPath);
            }

            public static string Arch { get; set; } = String.Empty;
            public static string Config { get; set; } = String.Empty;

            private static void ProcessCommandLine(string full_path)
            {
                var parts = full_path.Split(
                    new[] { Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar },
                    StringSplitOptions.RemoveEmptyEntries);

                for (int i = parts.Length - 1; i >= 0; --i)
                {
                    if (string.Equals(parts[i], "build", StringComparison.OrdinalIgnoreCase))
                    {
                        if (i + 2 >= parts.Length)
                            break;

                        Arch = parts[i + 1];
                        Config = parts[i + 2];

                        return;
                    }
                }

                throw new InvalidOperationException(
                    $"Expected path segment 'build/<arch>/<config>'. Path='{full_path}'");
            }
        }

        #endregion

        #region Private Methods

        private static Env Create()
        {
            var repo_root = Repo.GetRoot();

            return new Env(repo_root);
        }

        #endregion

        #region Private Fields

        private static readonly Lazy<Env> s_env = new(Create, System.Threading.LazyThreadSafetyMode.ExecutionAndPublication);
        private static ILogger? s_logger = null;
        public static readonly AsyncLocal<LocalContext?> s_current = new();

        #endregion

    }

} // namespace Croicu.Templates.Test.Core
