using System;
using System.Collections.Generic;
using System.Text;

namespace Croicu.Templates.Test.Core
{
    public interface ITestLogger
    {
        void Info(string message);
        void Warn(string message);
        void Error(string message);
    }

    public sealed class EmptyLogger : ITestLogger
    {
        public static readonly EmptyLogger Instance = new();

        private EmptyLogger()
        {
        }

        public void Info(string message)
        {
        }

        public void Warn(string message)
        {
        }

        public void Error(string message)
        {
        }
    }
}
