using System;
using System.Collections.Generic;
using System.Text;

namespace Croicu.Templates.Test.Core
{
    public enum LogLevel
    {
        Verbose,
        Debug,
        Info,
        Warn,
        Error,
        Fatal,
    };

    public interface ILogger
    {
        void Log(LogLevel level, string message);
        void Log(LogLevel level, string message, Exception exception);
    }

    internal class Logger: ILogger
    {
        public void Log(LogLevel level, string message)
        {
            System.Console.WriteLine($"[{level}] {message}");
        }

        public void Log(LogLevel level, string message, Exception exception)
        {
            System.Console.WriteLine($"[{level}] {message} - {exception.Message}");
        }
    }
}
