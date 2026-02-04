using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Text.Json;

namespace Croicu.Templates.Test.Core
{

    #region Public Types

    public sealed class HostInfo
    {
        public string Name { get; set; } = "";
        public string Dir { get; set; } = "";

        public TemplateFileInfo[] Files { get; set; } = System.Array.Empty<TemplateFileInfo>();
    }

    #endregion

    public class TemplateHosts
    {
        public static IEnumerable<HostInfo> LoadHosts()
        {
            if (hostSettings == null)
            {
                var path = Path.Combine(Context.TestSettingsDir, hostSettingsFileName);
                var json = File.ReadAllText(path);

                hostSettings = JsonSerializer.Deserialize<List<HostInfo>>(json);
                if (hostSettings == null)
                {
                    throw new InvalidDataException($"Failed to parse JSON: {path}");
                }
            }

            foreach (var HostInfo in hostSettings)
            {
                yield return new HostInfo
                {
                    Name = HostInfo.Name,
                    Dir = HostInfo.Dir,
                    Files = HostInfo.Files
                };
            }
        }

        public static HostInfo GetByName(string name)
        {
            IEnumerable<HostInfo> hostInfos = LoadHosts().Where(t => t.Name == name);

            if (hostInfos.Count() == 0)
            {
                throw new InvalidDataException($"Host not found: {name}");
            }
            else if (hostInfos.Count() > 1)
            {
                throw new InvalidDataException($"Multiple entries for host: {name}");
            }

            return hostInfos.ElementAt(0);
        }

        #region Private Fileds

        private static string hostSettingsFileName = "hosts.json";
        private static List<HostInfo>? hostSettings = null;

        #endregion

        #region Private Methods

        private static IEnumerable<object[]> GetByType(string type)
        {
            foreach (var HostInfo in LoadHosts())
                yield return new object[]
                {
                    HostInfo.Name,
                    HostInfo.Dir,
                    HostInfo.Files
                };
        }

        #endregion

    }
}
