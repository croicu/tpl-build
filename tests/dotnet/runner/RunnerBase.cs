using Croicu.Templates.Test.Core;
using System;
using System.Collections.Generic;
using System.Text;

namespace Croicu.Templates.Test.Runner
{
    internal abstract class RunnerBase
    {
        protected abstract int DoRun(TemplateInfo templateInfo);

        internal int Run(TemplateInfo templateInfo)
        {
            Init (templateInfo);
            try
            {
                return DoRun(templateInfo);
            }
            finally
            {
                Done(templateInfo);
            }
        }

        private void Init(TemplateInfo templateInfo)
        {
            Context.Current.TestClassName = this.GetType().FullName ?? this.GetType().Name;
            Context.Current.TestName = "Run";
            Context.Current.TestTemplate = "__" + templateInfo.Name + "__";
        }

        private void Done(TemplateInfo templateInfo)
        {
            Context.Current.Done();
        }
    }
}
