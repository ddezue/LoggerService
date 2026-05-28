using System;
using System.IO;

namespace LoggerService {
  public sealed class Logger {
    private static readonly Logger s_instance = new Logger();
    private readonly string _logFilePath = "application.log";

    private Logger() {
      string initialMessage = $"Logging started at {DateTime.Now:yyyy-MM-dd HH:mm:ss}";
      File.WriteAllText(_logFilePath, initialMessage + Environment.NewLine);
    }

    public static Logger Instance { get; } = s_instance;

    public void Log(string message, string level) {
      string formattedTime = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
      string logEntry = $"{formattedTime} [{level}] {message}";
      Console.WriteLine(logEntry);
      File.AppendAllText(_logFilePath, logEntry + Environment.NewLine);
    }

    public void Info(string message) {
      Log(message, "INFO");
    }

    public void Warning(string message) {
      Log(message, "WARNING");
    }

    public void Error(string message) {
      Log(message, "ERROR");
    }
  }
}