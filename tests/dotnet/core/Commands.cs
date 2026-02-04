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

        public static bool VerifyDeployed(string destDir, TemplateFileInfo[] templateSettings)
        {
            Console.WriteLine($"[Info] Verifying: {destDir} ...");

            foreach (TemplateFileInfo fileInfo in templateSettings)
            {
                string filePath = Path.Combine(destDir, fileInfo.FileName);

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

        public static bool VerifyBuilt(string outDir, string[] fileNames)
        {
            Console.WriteLine($"[Info] Verifying: {outDir} ...");

            foreach (string fileName in fileNames)
            {
                string filePath = Path.Combine(outDir, fileName);

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
                string hostDir = Path.Combine(Context.TestDataDir, "hosts", hostInfo.Dir);

                TemplateInstantiator.Instantiate(hostDir, destDir, projectName, hostInfo.Files);
            }

            return true;
        }

        public static bool Build(string destDir)
        {
            int exitCode;

            Console.WriteLine($"[Info] Building: {destDir} ...");

            exitCode = Builder.Build("cmd.exe", destDir, $"/c build.bat {Context.Config} {Context.Arch}");
            if (exitCode != 0)
            {
                Console.WriteLine($"[Error] Build failed, exit code: {exitCode}.");
                return false;
            }

            return true;
        }

        public static bool Execute(string exePath)
        {
            string? exeDir = Path.GetDirectoryName(exePath);

            Console.WriteLine($"[Info] Executing: {exePath} ...");
            if (
                String.IsNullOrWhiteSpace(exeDir) ||
                !Directory.Exists(exeDir) ||
                !File.Exists(exePath))
            {
                Console.WriteLine($"[Error] Executable not found: {exePath}.");
                return false;
            }

            int exitCode = Executor.Execute(exePath, exeDir);
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
