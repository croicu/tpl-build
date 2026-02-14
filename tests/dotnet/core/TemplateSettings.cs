using System;
using System.Collections.Generic;
using System.Text;
using System.Text.Json;
using System.Runtime.InteropServices;

namespace Croicu.Templates.Test.Core
{

    #region Public Types

    public sealed class TemplateFileInfo
    {
        public string FileName { get; set; } = "";
        public string TargetFileName
        {
            get
            {
                if (string.IsNullOrEmpty(m_targetFileName))
                {
                    return FileName;
                }
                
                if (!m_isSubstituted)
                {
                    m_targetFileName = TemplateInstantiator.Substitute(m_targetFileName);
                    m_isSubstituted = true;
                }

                return m_targetFileName;
            }
            set
            {
                m_targetFileName = value;
                m_isSubstituted = false;
            } 
        }

        public bool Substitute { get; set; } = false;
        public string[] Platforms { get; set; } = {};

        public bool IsBuilt()
        {
            if (Platforms.Length == 0 ||
                RuntimeInformation.IsOSPlatform(OSPlatform.Windows) && Platforms.Contains("Windows") ||
                RuntimeInformation.IsOSPlatform(OSPlatform.Linux) && Platforms.Contains("Linux"))
                return true;

            return false;
        }

        private string m_targetFileName = "";
        private bool m_isSubstituted = false;
    }

    public sealed class TemplateInfo
    {
        public string Name { get; set; } = "";
        public string FileName { get; set; } = "";
        public string Type { get; set; } = "";
        public string[] Platforms { get; set; } = {};
        public string HostName { get; set; } = "";

        public TemplateFileInfo[] Files { get; set; } = System.Array.Empty<TemplateFileInfo>();
        public TemplateFileInfo[] BuiltFiles { get; set; } = System.Array.Empty<TemplateFileInfo>();
    }

    #endregion

    public class TemplateSettings
    {
        public static IEnumerable<TemplateInfo> LoadTemplates()
        {
            if (templateSettings == null)
            {
                var path = Path.Combine(Context.TestSettingsDir, templateSettingsFileName);
                var json = File.ReadAllText(path);
                
                templateSettings = JsonSerializer.Deserialize<List<TemplateInfo>>(json);
                if (templateSettings == null)
                {
                    throw new InvalidDataException($"Failed to parse JSON: {path}");
                }
            }

            foreach (var templateInfo in templateSettings)
            {
                yield return new TemplateInfo
                {
                    Name = templateInfo.Name,
                    FileName = templateInfo.FileName,
                    Type = templateInfo.Type,
                    Platforms = templateInfo.Platforms,
                    HostName = templateInfo.HostName,
                    Files = templateInfo.Files,
                    BuiltFiles = templateInfo.BuiltFiles
                };
            }
        }

        public static IEnumerable<object[]> GetConsole() =>
            GetByType("Console");

        public static IEnumerable<object[]> GetWin32() =>
            GetByType("Win32");

        public static IEnumerable<object[]> GetModule() =>
            GetByType("Module");

        public static IEnumerable<object[]> GetLibrary() =>
            GetByType("Library");

        #region Private Fileds

        private static string templateSettingsFileName = "templates.json";
        private static List<TemplateInfo>? templateSettings = null;

        #endregion

        #region Private Methods

        private static IEnumerable<object[]> GetByType(string type)
        {
            foreach (var templateInfo in LoadTemplates().Where(t => t.Type == type))
                yield return new object[]
                {
                    templateInfo.Name,
                    templateInfo.FileName,
                    templateInfo.HostName,
                    templateInfo.Platforms,
                    templateInfo.Files,
                    templateInfo.BuiltFiles
                };
        }

        #endregion

    }
}
