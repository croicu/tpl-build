using System;
using System.IO;
using System.IO.Compression;

namespace Croicu.Templates.Test.Core
{

    public sealed class ZipExpandOptions
    {
        public bool OverwriteFiles { get; init; } = true;
        public bool CreateDirectories { get; init; } = true;
        public bool PreserveTimestamps { get; init; } = true;
    }

    public static class TemplateExpander
    {
        public static void ExpandToDirectory(
            string zipPath,
            string destinationDir,
            ZipExpandOptions? options = null)
        {
            ArgumentException.ThrowIfNullOrEmpty(zipPath);
            ArgumentException.ThrowIfNullOrEmpty(destinationDir);

            options ??= new ZipExpandOptions();
            ILogger logger = Context.Logger;

            zipPath = Path.GetFullPath(zipPath);
            destinationDir = Path.GetFullPath(destinationDir);

            if (!File.Exists(zipPath))
                throw new FileNotFoundException($"Zip file not found: {zipPath}", zipPath);

            Directory.CreateDirectory(destinationDir);
            destinationDir = Helpers.EnsureTrailingSeparator(destinationDir);
            logger.Log(LogLevel.Debug, $"Expanding ZIP: {zipPath} to:");
            logger.Log(LogLevel.Debug, $"   {destinationDir}");

            using var archive = ZipFile.OpenRead(zipPath);
            foreach (var entry in archive.Entries)
            {
                var entryPath = entry.FullName.Replace('\\', '/');

                if (string.IsNullOrWhiteSpace(entryPath))
                    continue;

                if (entryPath.EndsWith("/", StringComparison.Ordinal))
                {
                    if (!options.CreateDirectories)
                        continue;

                    var dir_target = Helpers.SafeCombine(destinationDir, entryPath);
                    Directory.CreateDirectory(dir_target);

                    continue;
                }

                var destPath = Helpers.SafeCombine(destinationDir, entryPath);
                var destDir = Path.GetDirectoryName(destPath);
                if (!string.IsNullOrEmpty(destDir))
                    Directory.CreateDirectory(destDir);

                if (!options.OverwriteFiles && File.Exists(destPath))
                {
                    logger.Log(LogLevel.Warn, $"Skip existing: {destPath}");
                    continue;
                }

                logger.Log(LogLevel.Debug, $"Extract: {entryPath}");

                using var entryStream = entry.Open();
                using var outStream = new FileStream(
                    destPath,
                    options.OverwriteFiles ? FileMode.Create : FileMode.CreateNew,
                    FileAccess.Write,
                    FileShare.Read);

                entryStream.CopyTo(outStream);

                if (options.PreserveTimestamps)
                {
                    try
                    {
                        File.SetLastWriteTimeUtc(destPath, entry.LastWriteTime.UtcDateTime);
                    } catch {}
                }
            }
        }
    }

} // namespace Croicu.Templates.Test.Core
