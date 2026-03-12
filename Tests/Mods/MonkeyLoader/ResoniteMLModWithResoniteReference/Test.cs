using MonkeyLoader.Resonite;
using System;
using System.Collections.Generic;
using System.Text;

namespace ResoniteModWithResoniteReference
{
    internal sealed class Test : ResoniteMonkey<Test>
    {
        protected override bool OnEngineReady()
        {
            Logger.Info(() => $"Look, it's a Resonite type: {typeof(FrooxEngine.LineSegment).AssemblyQualifiedName}");

            return base.OnEngineReady();
        }
    }
}