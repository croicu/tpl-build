using Croicu.Templates.Test.Core;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Runtime.CompilerServices;
using System.Text;

namespace Croicu.Templates.Test.Core
{
    public sealed class TemplateInstantiator
    {
        public static void Instantiate(
            string stagingDir,
            string destDir,
            string projectName,
            TemplateFileInfo[] templateFiles)
        {
            ArgumentNullException.ThrowIfNull(stagingDir);
            ArgumentNullException.ThrowIfNull(destDir);

            stagingDir = Path.GetFullPath(stagingDir);
            destDir = Path.GetFullPath(destDir);

            if (!Directory.Exists(stagingDir))
                throw new DirectoryNotFoundException($"Staging folder not found: '{stagingDir}'");

            Directory.CreateDirectory(destDir);
            var substitutions = new Dictionary<string, string>
            {
                { "safeprojectname",    projectName},
                { "installpath",        getInstallPath()}
            };

            foreach (TemplateFileInfo fileInfo in templateFiles)
            {
                var srcFilePath = Path.Combine(stagingDir, fileInfo.FileName);
                var destFilePath = Path.Combine(destDir, fileInfo.FileName);
                var destFileDir = Path.GetDirectoryName(destFilePath);

                if (!string.IsNullOrEmpty(destFileDir))
                    Directory.CreateDirectory(destFileDir);

                if (fileInfo.Substitute)
                {
                    var text = ReadAll(srcFilePath);
                    var substituted = ApplySubstitutions(text, substitutions);

                    WriteAll(destFilePath, substituted);
                }
                else
                {
                    File.Copy(srcFilePath, destFilePath, overwrite: true);
                }
            }
        }

        static string? installPath = null;

        private static string getInstallPath()
        {
            const string wswhere = @"C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe";
            const string arguments = "-latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath";

            if (installPath == null)
            {
                int exitCode;
                string stdout;
                string stderr;

                try
                {
                    exitCode = Executor.Execute(wswhere, arguments, string.Empty, out stdout, out stderr);
                }
                catch (Exception ex)
                {
                    throw new FileNotFoundException("Vswhere not found.", ex);
                }

                if (exitCode != 0)
                {
                    throw new ApplicationException($"Vswhere error.\n[STDOUT] {stdout}.\n[STDERR] {stderr}.\n");
                }

                installPath = stdout.TrimEnd() + @"\Common7\IDE\";
            }

            return installPath;
        }

        private static string ApplySubstitutions(string input, IReadOnlyDictionary<string, string> substitutions)
        {
            if (substitutions.Count == 0)
                return input;

            var output = input;
            foreach (var kv in substitutions)
            {
                var key = kv.Key ?? string.Empty;
                var value = kv.Value ?? string.Empty;

                var token = WrapToken(key);
                output = output.Replace(token, value, StringComparison.Ordinal);
            }

            return output;
        }

        private static string WrapToken(string key)
        {
            // If caller already included $...$, keep it.
            if (key.Length >= 2 && key[0] == '$' && key[^1] == '$')
                return key;

            return "$" + key + "$";
        }


        private static string ReadAll(string path)
        {
            // detectEncodingFromByteOrderMarks preserves UTF-8/UTF-16/UTF-32 BOM detection.
            using var fs = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.Read);
            using var sr = new StreamReader(fs, Encoding.ASCII);

            var text = sr.ReadToEnd();

            return text;
        }

        private static void WriteAll(string path, string text)
        {
            // Preserve detected encoding. StreamWriter will emit BOM if the encoding uses one.
            using var fs = new FileStream(path, FileMode.Create, FileAccess.Write, FileShare.None);
            using var sw = new StreamWriter(fs, Encoding.ASCII);

            sw.Write(text);
        }
    }
}
