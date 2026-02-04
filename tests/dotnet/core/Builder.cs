using System;
using System.Collections.Generic;
using System.Text;
using System.Diagnostics;

namespace Croicu.Templates.Test.Core
{
    public class Builder
    {
        public static int Build(string commandfileName, string workingDirectory, string arguments)
        {
            var psi = new ProcessStartInfo
            {
                FileName = commandfileName,
                WorkingDirectory = workingDirectory,
                Arguments = arguments,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
                CreateNoWindow = true
            };
            var process = Process.Start(psi);
            var logger = Context.Logger;

            if (process == null)
                return -1;

            process.WaitForExit();

            // read output
            string stdout = process.StandardOutput.ReadToEnd();
            string stderr = process.StandardError.ReadToEnd();

            logger.Log(LogLevel.Debug, "STDOUT:");
            logger.Log(LogLevel.Debug, stdout);

            if (!string.IsNullOrWhiteSpace(stderr))
            {
                logger.Log(LogLevel.Debug, "STDERR:");
                logger.Log(LogLevel.Debug, stderr);
            }

            return process.ExitCode;

        }
    }
}
