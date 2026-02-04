using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text;

namespace Croicu.Templates.Test.Core {

internal static class Helpers
{
    internal static string SafeCombine(
        string destDir, 
        string entryFullName)
    {
        var relative = entryFullName.TrimStart('/');
        var combined = Path.GetFullPath(
            Path.Combine(
                destDir, relative.Replace('/', Path.DirectorySeparatorChar)));

        if (!combined.StartsWith(destDir, StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException(
                $"Zip entry escapes destination: '{entryFullName}' => '{combined}'");

        return combined;
    }

    internal static string EnsureTrailingSeparator(string dir)
    {
        if (dir.EndsWith(Path.DirectorySeparatorChar))
            return dir;
        if (dir.EndsWith(Path.AltDirectorySeparatorChar))
            return dir;

        return dir + Path.DirectorySeparatorChar;
    }

    private static bool EndsWith(this string s, char c) =>
        s.Length > 0 && s[^1] == c;
}

public static class Repo
{
    public static string GetRoot()
    {
        if (!string.IsNullOrEmpty(s_root))
            return s_root;

        var psi = new ProcessStartInfo
        {
            FileName = "git",
            Arguments = "rev-parse --show-toplevel",
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            UseShellExecute = false,
            CreateNoWindow = true
        };

        using var process = Process.Start(psi)
            ?? throw new InvalidOperationException("Failed to start git process.");

        var stdout = process.StandardOutput.ReadToEnd();
        var stderr = process.StandardError.ReadToEnd();

        process.WaitForExit();

        if (process.ExitCode != 0)
        {
            throw new InvalidOperationException(
                $"git rev-parse --show-toplevel failed (exit {process.ExitCode}).\n{stderr}");
        }

        var path = stdout.Trim();

        if (string.IsNullOrEmpty(path) || !Directory.Exists(path))
        {
            throw new InvalidOperationException(
                $"git returned invalid repository root: '{path}'");
        }

        s_root = Path.GetFullPath(path);

        return s_root;
    }

    public static void SetRoot(string root)
    {
        s_root = root;
    }

    private static string s_root = string.Empty;
}

} // namespace Croicu.Templates.Test.Core
