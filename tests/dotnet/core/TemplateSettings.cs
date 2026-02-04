using System;
using System.Collections.Generic;
using System.Text;
using System.Text.Json;

namespace Croicu.Templates.Test.Core
{

    #region Public Types

    public sealed class TemplateFileInfo
    {
        public string FileName { get; set; } = "";
        public bool Substitute { get; set; } = false;
    }

    public sealed class TemplateInfo
    {
        public string Name { get; set; } = "";
        public string FileName { get; set; } = "";
        public string Type { get; set; } = "";
        public string HostName { get; set; } = "";

        public TemplateFileInfo[] Files { get; set; } = System.Array.Empty<TemplateFileInfo>();
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
                    HostName = templateInfo.HostName,
                    Files = templateInfo.Files
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
                    templateInfo.Files
                };
        }

        #endregion

    }
}
