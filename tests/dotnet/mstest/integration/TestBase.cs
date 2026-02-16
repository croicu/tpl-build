using System;
using System.Collections.Generic;
using System.Text;

using Microsoft.VisualStudio.TestTools.UnitTesting;

using Croicu.Templates.Test.Core;

namespace Croicu.Templates.Test.Integration
{
    public class TestBase
    {

        public TestBase()
        {
        }

        #region Public Properties

        public TestContext TestContext
        {
            get
            {
                return s_current.Value!;
            }
            set
            {
                s_current.Value = value;

                Context.Current.TestClassName = value.FullyQualifiedTestClassName;
                Context.Current.TestName = value.TestName;

                if (value.TestData != null)
                {
                    TemplateInfo? testTemplate = value.TestData.GetValue(0) as TemplateInfo;

                    if (testTemplate != null)
                    {
                        Context.Current.TestTemplate = "__" + testTemplate.Name + "__";
                    }
                }
            }
        }

        #endregion

        #region Private Members

        public static readonly AsyncLocal<TestContext?> s_current = new();

        #endregion

    }

}
