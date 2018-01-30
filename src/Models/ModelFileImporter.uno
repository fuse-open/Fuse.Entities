using Uno.Compiler;
using Uno.Compiler.ExportTargetInterop;
using Uno.Compiler.ImportServices;
using Uno.IO;

namespace Fuse.Content.Models
{
    [DontExport]
    public sealed class ModelFileImporter : Importer<BundleFile>
    {
        public extern ModelFileImporter([Filename] string filename);

        public override extern string GetCacheKey();
        public override extern BundleFile Import(ImporterContext ctx);
    }
}
