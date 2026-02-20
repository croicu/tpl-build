using System;
using System.Collections.Generic;
using System.Reflection.Metadata;
using System.Runtime.InteropServices;
using System.Text;

namespace Croicu.Templates.Test.Core
{
    public static class Commands
    {
        public static bool Clean(String destDir)
        {
            Console.WriteLine($"[Info] Cleaning: {destDir} ...");

            if (Directory.Exists(destDir))
            {
                try
                {
                    Directory.Delete(destDir, true);
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[Error] Failed to delete {destDir}\nError: {ex.Message}.");
                    return false;
                }
            }

            return true;
        }

        public static bool Deploy(string zipPath, string stagingDir)
        {
            Console.WriteLine($"[Info] Deploying: {zipPath} to:");
            Console.WriteLine($"[Info]  {stagingDir} ...");

            try
            {
                TemplateExpander.ExpandToDirectory(zipPath, stagingDir);
                Console.WriteLine($"[Info] Expanded: {zipPath} to:");
                Console.WriteLine($"[Info]  {stagingDir}");
            }
            catch (FileNotFoundException)
            {
                Console.WriteLine($"[Error] File not found: {zipPath}.");

                return false;
            }

            return true;
        }

        private static string GetFileName(TemplateFileInfo file, bool isInstantiated)
        {
            if (isInstantiated)
            {
                return file.TargetFileName;
            }
            else
            {
                return file.FileName;
            }
        }

        public static bool VerifyDeployed(string destDir, TemplateFileInfo[] files, bool isInstantiated)
        {
            Console.WriteLine($"[Info] Verifying: {destDir} ...");

            foreach (TemplateFileInfo file in files)
            {
                string fileName = GetFileName(file, isInstantiated);
                string filePath = Path.Combine(destDir, fileName);

                if (File.Exists(filePath))
                {
                    Console.WriteLine($"[Info]     Found file: {filePath}.");
                }
                else
                {
                    Console.WriteLine($"[Error]    File not found: {filePath}.");
                    return false;
                }
            }

            return true;
        }

        public static bool ShouldBuild(string templateName, string[] platforms)
        {
            if (platforms.Length == 0)
            {
                Console.WriteLine($"[Info] Skipping build test for template {templateName} does not specify a target platform.");

                return false;
            }

            if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows) && platforms.Contains("Windows"))
            {
                Console.WriteLine($"[Info] Testing build for template {templateName} on platform: Windows.");

                return true;
            }
            else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux) && platforms.Contains("Linux"))
            {
                Console.WriteLine($"[Info] Testing build for template {templateName} on platform: Linux.");

                return true;
            }
            else
            {
                Console.WriteLine($"[Info] Skipping build test for template {templateName} is not supported on this platform.");

                return false;
            }
        }

        public static bool VerifyBuilt(string outDir, TemplateFileInfo[] builtFiles)
        {
            Console.WriteLine($"[Info] Verifying: {outDir} ...");

            foreach (TemplateFileInfo file in builtFiles)
            {
                if (file.IsBuilt())
                {
                    string filePath = Path.Combine(outDir, file.TargetFileName);

                    if (File.Exists(filePath))
                    {
                        Console.WriteLine($"[Info]     Found file: {filePath}.");
                    }
                    else
                    {
                        Console.WriteLine($"[Error]    File not found: {filePath}.");
                        return false;
                    }
                }
            }

            return true;
        }

        public static bool InstantiateTemplate(string stagingDir, string destDir, string projectName, TemplateFileInfo[] templateFiles)
        {
            Console.WriteLine($"[Info] Instantiating: {stagingDir} to {destDir} ...");

            TemplateInstantiator.Instantiate(stagingDir, destDir, projectName, templateFiles);
            return true;
        }

        public static bool InstantiateHost(string destDir, string hostName, string projectName)
        {
            Console.WriteLine($"[Info] Instantiating: {hostName} to {destDir} ...");

            {
                HostInfo hostInfo = TemplateHosts.GetByName(hostName);
                string hostDir = Path.Combine(Context.TestHostsDir, hostInfo.Dir);

                TemplateInstantiator.Instantiate(hostDir, destDir, projectName, hostInfo.Files);
            }

            return true;
        }

        public static bool Build(string destDir)
        {
            int exitCode;
            string commandFileName;
            string commandArgs;

            if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
            {
                commandFileName = "cmd.exe";
                commandArgs = $"/c build.bat {Context.Config.ToLower()} {Context.Arch}";
            }
            else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
            {
                commandFileName = "bash";
                commandArgs = $"./build.sh {Context.Config.ToLower()} {Context.Arch}";
            }
            else
            {
                throw new PlatformNotSupportedException("Unsupported platform");
            }

            Console.WriteLine($"[Info] Building: {destDir} ...");

            exitCode = Builder.Build(commandFileName, destDir, commandArgs);
            if (exitCode != 0)
            {
                Console.WriteLine($"[Error] Build failed, exit code: {exitCode}.");
                return false;
            }

            return true;
        }

        public static bool Execute(string exePath)
        {
            string? exeDir = Path.GetDirectoryName(Path.GetFullPath(exePath));
            var env = new Dictionary<string,string>();

            Console.WriteLine($"[Info] Executing: {exePath} ...");
            if (
                String.IsNullOrWhiteSpace(exeDir) ||
                !Directory.Exists(exeDir) ||
                !File.Exists(Path.GetFullPath(exePath)))
            {
                Console.WriteLine($"[Error] Executable not found: {exePath}.");
                return false;
            }

            if (OperatingSystem.IsLinux())
            {
                var existing = Environment.GetEnvironmentVariable("LD_LIBRARY_PATH");
                
                env["LD_LIBRARY_PATH"] =
                    string.IsNullOrEmpty(existing)
                        ? exeDir
                        : $"{exeDir}:{existing}";
            }

            int exitCode = Executor.Execute(exePath, exeDir, null, env);
            if (exitCode != 0)
            {
                Console.WriteLine($"[Error] Execute failed, executable: {exePath}, exit code: {exitCode}.");
                return false;
            }

            return true;
        }

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        private delegate int MainDelegate(int x);

        private static int CallModule(string dllPath, int argument)
        {
            IntPtr dll = IntPtr.Zero;
            IntPtr fn;
            MainDelegate main;

            try
            {
                dll = NativeLibrary.Load(dllPath);
                fn = NativeLibrary.GetExport(dll, "module");
                main = Marshal.GetDelegateForFunctionPointer<MainDelegate>(fn);

                return main(argument);
            }
            catch (DllNotFoundException)
            {
                Console.WriteLine($"[Error] DLL missing or dependency missing: {dllPath}.");

                throw;
            }
            catch (BadImageFormatException)
            {
                Console.WriteLine($"[Error] Architecture mismatch or invalid DLL: {dllPath}.");

                throw;
            }
            catch (EntryPointNotFoundException)
            {
                Console.WriteLine($"[Error] Exported function 'main' not found: {dllPath}.");

                throw;
            }
            catch (MarshalDirectiveException)
            {
                Console.WriteLine($"[Error] Function 'main' Signature mismatch: {dllPath}.");

                throw;
            }
            catch (AccessViolationException)
            {
                Console.WriteLine($"[Error] Calling convention mismatch or crash in native code: {dllPath}.");

                throw;
            }
            finally
            {
                NativeLibrary.Free(dll);
            }
        }

        public static bool Invoke(string dllPath)
        {
            string? dllDir = Path.GetDirectoryName(dllPath);
            int expected = 1;
            int argument = 1;

            Console.WriteLine($"[Info] Executing: {dllPath} ...");
            if (
                String.IsNullOrWhiteSpace(dllDir) ||
                !Directory.Exists(dllDir) ||
                !File.Exists(dllPath))
            {
                Console.WriteLine($"[Error] Executable not found: {dllPath}.");
                return false;
            }

            try
            {
                if (expected != CallModule(dllPath, argument))
                {
                    Console.WriteLine($"[Error] Unexpected value returned by main function: {dllPath}.");
                    return false;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Info] Exception: {ex.Message}.");
            }

            return true;
        }
    }
}
