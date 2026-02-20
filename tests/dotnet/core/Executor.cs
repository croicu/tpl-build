using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Diagnostics;

namespace Croicu.Templates.Test.Core
{
    public class Executor
    {
        public static int Execute(
            string fileName,
            string? arguments = null,
            string? directory = null,
            IDictionary<string, string>? environmentOverrides = null)
        {
            var logger = Context.Logger;
            string stdout;
            string stderr;

            int exitCode = Execute(fileName, arguments, directory, environmentOverrides, out stdout, out stderr);

            logger.Log(LogLevel.Debug, "STDOUT:");
            logger.Log(LogLevel.Debug, stdout);

            if (!string.IsNullOrWhiteSpace(stderr))
            {
                logger.Log(LogLevel.Debug, "STDERR:");
                logger.Log(LogLevel.Debug, stderr);
            }

            return exitCode;
        }

        public static int Execute(
            string  fileName,
            string? arguments,
            string? directory,
            IDictionary<string, string>? environmentOverrides,
            out string stdout,
            out string stderr)
        {
            stdout = String.Empty;
            stderr = String.Empty;

            if (arguments == null)
            {
                arguments = String.Empty;
            }
            if (string.IsNullOrEmpty(directory))
            {
                directory = Directory.GetCurrentDirectory();
            }

            var psi = new ProcessStartInfo
            {
                FileName = fileName,
                WorkingDirectory = directory,
                Arguments = arguments,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
                CreateNoWindow = true
            };
            if (environmentOverrides != null)
            {
                foreach (var kv in environmentOverrides)
                {
                    psi.Environment[kv.Key] = kv.Value;
                }
            }

            var process = Process.Start(psi);

            if (process == null)
            {
                return -1;
            }
            else
            {
                process.WaitForExit();
                // read output

                stdout = process.StandardOutput.ReadToEnd();
                stderr = process.StandardError.ReadToEnd();

                return process.ExitCode;
            }
        }
    }
}
